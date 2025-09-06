//
//  HomeViewModel.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
public class HomeViewModel: ObservableObject {
    @Published var storageInfo: StorageInfo?
    @Published var user: User = User()
    @Published var showingSettings = false
    @Published var errorMessage: String?
    @Published var showingScanResults = false
    
    private let userRepository: UserRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userRepository: UserRepositoryProtocol,
        imageRepository: ImageRepositoryProtocol
    ) {
        self.userRepository = userRepository
        self.imageRepository = imageRepository
        
        setupBindings()
        loadInitialData()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Public Methods
    
    func upgradeToPremium() {
        userRepository.purchasePremium()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in
                    // Premium purchase success handled via user repository's currentUser publisher
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshStorageInfo() {
        loadInitialData()
    }
    
    func updateStorageInfo(with scanResult: ScanResult) {
        guard var storage = storageInfo else { return }
        storage = StorageInfo(
            totalSpace: storage.totalSpace,
            usedSpace: storage.usedSpace,
            availableSpace: storage.availableSpace,
            cleanableSpace: scanResult.totalCleanableSpace
        )
        self.storageInfo = storage
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        userRepository.getCurrentUser()
            .receive(on: DispatchQueue.main)
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        imageRepository.getStorageInfo()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] storage in
                    self?.storageInfo = storage
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Computed Properties
extension HomeViewModel {
    var canPerformDeepScan: Bool {
        user.canPerformDeepScan
    }
}
