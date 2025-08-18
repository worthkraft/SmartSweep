//
//  UserRepository.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine
import StoreKit

// The UserRepositoryError is now in a separate file

public class UserRepository: UserRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let productID = "com.smartsweep.premium"
    
    @Published private var currentUser: User = User()
    
    public init() {
        loadUser()
    }
    
    public func getCurrentUser() -> AnyPublisher<User, Never> {
        return $currentUser.eraseToAnyPublisher()
    }
    
    public func updateUser(_ user: User) -> AnyPublisher<Void, Never> {
        return Future { promise in
            self.currentUser = user
            self.saveUser(user)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
    public func purchasePremium() -> AnyPublisher<Bool, Error> {
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
                            
                            // Update user to premium - capture current user to avoid concurrency issues
                            let currentUserSnapshot = self.currentUser
                            let updatedUserSnapshot: User = {
                                var userCopy = currentUserSnapshot
                                userCopy.isPremium = true
                                userCopy.purchaseDate = Date()
                                return userCopy
                            }()

                            await MainActor.run {
                                self.currentUser = updatedUserSnapshot
                                self.saveUser(updatedUserSnapshot)
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
    
    public func restorePurchases() -> AnyPublisher<Bool, Error> {
        return Future { promise in
            Task {
                do {
                    try await AppStore.sync()
                    
                    for await result in Transaction.currentEntitlements {
                        switch result {
                        case .verified(let transaction):
                            if transaction.productID == self.productID {
                                // Capture current user to avoid concurrency issues
                                let currentUserSnapshot = self.currentUser
                                let updatedUserSnapshot: User = {
                                    var userCopy = currentUserSnapshot
                                    userCopy.isPremium = true
                                    userCopy.purchaseDate = transaction.purchaseDate
                                    return userCopy
                                }()

                                await MainActor.run {
                                    self.currentUser = updatedUserSnapshot
                                    self.saveUser(updatedUserSnapshot)
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
