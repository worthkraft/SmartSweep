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
class HomeViewModel: ObservableObject {
    @Published var scanStatus: ScanStatus = .idle
    @Published var scanResult: ScanResult?
    @Published var storageInfo: StorageInfo?
    @Published var user: User = User()
    @Published var showingSettings = false
    @Published var showingPermissionAlert = false
    @Published var errorMessage: String?
    @Published var isAnimating = false
    
    private let cleanImagesUseCase: CleanImagesUseCase
    private let userRepository: UserRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        cleanImagesUseCase: CleanImagesUseCase,
        userRepository: UserRepositoryProtocol,
        imageRepository: ImageRepositoryProtocol
    ) {
        self.cleanImagesUseCase = cleanImagesUseCase
        self.userRepository = userRepository
        self.imageRepository = imageRepository
        
        setupBindings()
        loadInitialData()
    }
    
    func requestPermissionAndScan() {
        imageRepository.requestPhotoLibraryAccess()
            .sink { [weak self] granted in
                if granted {
                    self?.performSmartScan()
                } else {
                    self?.showingPermissionAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    func performSmartScan() {
        withAnimation(AppConstants.Animation.scanPulse) {
            isAnimating = true
        }
        
        scanStatus = .scanning
        errorMessage = nil
        
        cleanImagesUseCase.performSmartScan()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    withAnimation {
                        self?.isAnimating = false
                    }
                    
                    switch completion {
                    case .finished:
                        self?.scanStatus = .completed
                    case .failure(let error):
                        self?.scanStatus = .error(error.localizedDescription)
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] result in
                    self?.scanResult = result
                    self?.updateStorageInfo(with: result)
                }
            )
            .store(in: &cancellables)
    }
    
    func cleanDuplicates() {
        guard let result = scanResult else { return }
        
        cleanImagesUseCase.cleanDuplicates(result.duplicateGroups)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.performSmartScan() // Refresh data
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func cleanTemporaryImages() {
        guard let result = scanResult else { return }
        
        cleanImagesUseCase.cleanTemporaryImages(result.temporaryImages)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.performSmartScan() // Refresh data
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
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
                receiveValue: { [weak self] success in
                    if success {
                        // Premium purchase successful, user will be updated automatically
                    }
                }
            )
            .store(in: &cancellables)
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
    
    private func updateStorageInfo(with result: ScanResult) {
        guard var storage = storageInfo else { return }
        storage = StorageInfo(
            totalSpace: storage.totalSpace,
            usedSpace: storage.usedSpace,
            availableSpace: storage.availableSpace,
            cleanableSpace: result.totalCleanableSpace
        )
        self.storageInfo = storage
    }
}

// MARK: - Computed Properties
extension HomeViewModel {
    var canPerformScan: Bool {
        user.canPerformDeepScan && scanStatus != .scanning
    }
    
    var scanButtonText: String {
        switch scanStatus {
        case .idle:
            return AppConstants.Strings.smartScan
        case .scanning:
            return AppConstants.Strings.scanning
        case .completed:
            return AppConstants.Strings.smartScan
        case .error:
            return AppConstants.Strings.smartScan
        }
    }
    
    var hasSuggestions: Bool {
        guard let result = scanResult else { return false }
        return !result.duplicateGroups.isEmpty || !result.temporaryImages.isEmpty
    }
}
