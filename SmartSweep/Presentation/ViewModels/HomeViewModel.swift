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
    
    private func updateScanProgress() {
        scanProgress = 0.1 // Start at 10%
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            
            Task { @MainActor in
                // Only update if still scanning and not yet at 90%
                if self.scanStatus == .scanning && self.scanProgress < 0.9 {
                    self.scanProgress += 0.15 // Increment by 15%
                }
                // Don't stop timer here - let handleScanCompletion do it
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        print("Progress timer stopped") // Debug log
    }
    
    private func showScanSuccessMessage() {
        guard let result = scanResult else { return }
        
        let duplicateCount = result.duplicateCount
        let temporaryCount = result.temporaryCount
        let totalCleanable = ByteCountFormatter.string(fromByteCount: result.totalCleanableSpace, countStyle: .file)
        
        if duplicateCount > 0 || temporaryCount > 0 {
            let message = "Scan selesai! Ditemukan \(duplicateCount) duplikat dan \(temporaryCount) gambar sementara."
            scanSuccessMessage = "\(message) Total dapat dibersihkan: \(totalCleanable)"
        } else {
            scanSuccessMessage = "Scan selesai! Galeri Anda sudah bersih. " +
                "Tidak ada duplikat atau gambar sementara yang ditemukan."
        }
        
        // Auto-hide success message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.scanSuccessMessage = nil
        }
    }
    @Published var scanProgress: Double = 0.0
    @Published var scanResult: ScanResult?
    @Published var storageInfo: StorageInfo?
    @Published var user: User = User()
    @Published var showingSettings = false
    @Published var showingPermissionAlert = false
    @Published var errorMessage: String?
    @Published var isAnimating = false
    @Published var scanSuccessMessage: String?
    @Published var showingScanResults = false
    
    private let cleanImagesUseCase: CleanImagesUseCase
    private let userRepository: UserRepositoryProtocol
    private let imageRepository: ImageRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var progressTimer: Timer?
    
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
    
    deinit {
        Task { @MainActor in
            stopProgressTimer()
        }
        cancellables.removeAll()
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
    
    func requestPermissionOnly() {
        imageRepository.requestPhotoLibraryAccess()
            .sink { [weak self] granted in
                if !granted {
                    self?.showingPermissionAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    func performSmartScan() {
        print("Starting smart scan...") // Debug log
        imageRepository.requestPhotoLibraryAccess()
            .flatMap { [weak self] granted -> AnyPublisher<ScanResult, Error> in
                print("Permission result: \(granted)") // Debug log
                return self?.handlePermissionResult(granted) ??
                    Fail(error: CleanError.unknown("Sistem error")).eraseToAnyPublisher()
            }
            .timeout(.seconds(10), scheduler: DispatchQueue.main) // Add timeout
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    print("Scan completion: \(completion)") // Debug log
                    self?.handleScanCompletion(completion)
                },
                receiveValue: { [weak self] result in
                    print("Scan value received") // Debug log
                    self?.handleScanValue(result)
                    
                    // Force completion after receiving value
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if self?.scanStatus == .scanning {
                            print("Forcing scan completion") // Debug log
                            self?.completeScanSuccessfully()
                        }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func handlePermissionResult(_ granted: Bool) -> AnyPublisher<ScanResult, Error> {
        guard granted else {
            self.showingPermissionAlert = true
            return Fail(error: CleanError.permissionDenied).eraseToAnyPublisher()
        }
        
        startScanningProcess()
        return cleanImagesUseCase.performSmartScan()
    }
    
    private func startScanningProcess() {
        withAnimation(AppConstants.Animation.scanPulse) {
            self.isAnimating = true
        }
        
        self.scanStatus = .scanning
        self.scanProgress = 0.0
        self.errorMessage = nil
        self.scanSuccessMessage = nil
        
        self.updateScanProgress()
    }
    
    private func handleScanCompletion(_ completion: Subscribers.Completion<Error>) {
        // Stop progress timer immediately
        stopProgressTimer()
        
        // Stop animations
        withAnimation {
            self.isAnimating = false
        }
        
        switch completion {
        case .finished:
            completeScanSuccessfully()
        case .failure(let error):
            completeScanWithError(error)
        }
    }
    
    private func completeScanSuccessfully() {
        guard scanStatus == .scanning else { return } // Prevent multiple calls
        print("Scan completed successfully") // Debug log
        self.scanProgress = 1.0
        self.scanStatus = .completed
        showScanSuccessMessage()
        
        scheduleResultsDisplay()
    }
    
    private func completeScanWithError(_ error: Error) {
        self.scanStatus = .error(error.localizedDescription)
        self.errorMessage = error.localizedDescription
        self.scanProgress = 0.0
    }
    
    private func handleScanValue(_ result: ScanResult) {
        print("Scan result received: \(result.duplicateGroups.count) duplicates, " +
              "\(result.temporaryImages.count) temporary")
        self.scanResult = result
        updateStorageInfo(with: result)
    }
    
    private func scheduleResultsDisplay() {
        // Always show results view after successful scan, regardless of findings
        guard let scanResult else { return }
        showingScanResults = true
    }
    
    func cleanDuplicates() {
        guard let result = scanResult else { return }
        
        scanStatus = .scanning
        scanProgress = 0.0
        
        cleanImagesUseCase.cleanDuplicates(result.duplicateGroups)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.scanProgress = 1.0
                        self?.scanStatus = .completed
                        self?.performSmartScan() // Refresh data
                    case .failure(let error):
                        self?.scanStatus = .error(error.localizedDescription)
                        self?.errorMessage = error.localizedDescription
                        self?.scanProgress = 0.0
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func cleanTemporaryImages() {
        guard let result = scanResult else { return }
        
        scanStatus = .scanning
        scanProgress = 0.0
        
        cleanImagesUseCase.cleanTemporaryImages(result.temporaryImages)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.scanProgress = 1.0
                        self?.scanStatus = .completed
                        self?.performSmartScan() // Refresh data
                    case .failure(let error):
                        self?.scanStatus = .error(error.localizedDescription)
                        self?.errorMessage = error.localizedDescription
                        self?.scanProgress = 0.0
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
    
    func clearScanResults() {
        stopProgressTimer() // Stop any running progress timer
        scanResult = nil
        scanStatus = .idle
        scanProgress = 0.0
        errorMessage = nil
        scanSuccessMessage = nil
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
    
    var scanProgressText: String {
        switch scanStatus {
        case .scanning:
            return "Memindai... \(Int(scanProgress * 100))%"
        case .completed:
            return "Scan Selesai"
        case .error:
            return "Scan Gagal"
        case .idle:
            return ""
        }
    }
    
    var hasSuggestions: Bool {
        guard let result = scanResult else { return false }
        return !result.duplicateGroups.isEmpty || !result.temporaryImages.isEmpty
    }
}
