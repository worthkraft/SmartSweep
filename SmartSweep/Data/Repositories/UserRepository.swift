//
//  UserRepository.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine
import StoreKit

class UserRepository: UserRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let productID = "com.smartsweep.premium"
    
    @Published private var currentUser: User = User()
    
    init() {
        loadUser()
    }
    
    func getCurrentUser() -> AnyPublisher<User, Never> {
        return $currentUser.eraseToAnyPublisher()
    }
    
    func updateUser(_ user: User) -> AnyPublisher<Void, Never> {
        return Future { promise in
            self.currentUser = user
            self.saveUser(user)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    func purchasePremium() -> AnyPublisher<Bool, Error> {
        return Future { promise in
            Task {
                do {
                    // Request products
                    let products = try await Product.products(for: [self.productID])
                    guard let product = products.first else {
                        promise(.failure(UserRepositoryError.productNotFound))
                        return
                    }
                    
                    // Purchase product
                    let result = try await product.purchase()
                    
                    switch result {
                    case .success(let verification):
                        switch verification {
                        case .verified(let transaction):
                            await transaction.finish()
                            
                            // Update user to premium
                            var updatedUser = self.currentUser
                            updatedUser.isPremium = true
                            updatedUser.purchaseDate = Date()
                            
                            await MainActor.run {
                                self.currentUser = updatedUser
                                self.saveUser(updatedUser)
                            }
                            
                            promise(.success(true))
                        case .unverified:
                            promise(.failure(UserRepositoryError.verificationFailed))
                        }
                    case .pending:
                        promise(.success(false))
                    case .userCancelled:
                        promise(.success(false))
                    @unknown default:
                        promise(.failure(UserRepositoryError.unknown("Unknown purchase result")))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func restorePurchases() -> AnyPublisher<Bool, Error> {
        return Future { promise in
            Task {
                do {
                    try await AppStore.sync()
                    
                    for await result in Transaction.currentEntitlements {
                        switch result {
                        case .verified(let transaction):
                            if transaction.productID == self.productID {
                                var updatedUser = self.currentUser
                                updatedUser.isPremium = true
                                updatedUser.purchaseDate = transaction.purchaseDate
                                
                                await MainActor.run {
                                    self.currentUser = updatedUser
                                    self.saveUser(updatedUser)
                                }
                                
                                promise(.success(true))
                                return
                            }
                        case .unverified:
                            continue
                        }
                    }
                    
                    promise(.success(false))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func loadUser() {
        if let data = userDefaults.data(forKey: "user"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }
    
    private func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            userDefaults.set(data, forKey: "user")
        }
    }
}

enum UserRepositoryError: LocalizedError {
    case productNotFound
    case verificationFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Produk tidak ditemukan"
        case .verificationFailed:
            return "Verifikasi pembelian gagal"
        case .unknown(let message):
            return message
        }
    }
}
