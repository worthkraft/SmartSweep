//
//  ScanViewModel.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
public class ScanResultsViewModel: ObservableObject {
    @Published var scanResult: ScanResult?
    @Published var errorMessage: String?
    @Published var isAnimating = false
    @Published var scanSuccessMessage: String?
    @Published var showingPermissionAlert = false
    
    private let cleanImagesUseCase: CleanImagesUseCase
    private let imageRepository: ImageRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var progressTimer: Timer?
    
    public init(cleanImagesUseCase: CleanImagesUseCase, imageRepository: ImageRepositoryProtocol, scanResult: ScanResult? = nil) {
        self.cleanImagesUseCase = cleanImagesUseCase
        self.imageRepository = imageRepository
        self.scanResult = scanResult
    }
    
    deinit {
        // Stop timer synchronously to avoid capturing self in async context
        if let timer = progressTimer {
            timer.invalidate()
        }
        cancellables.removeAll()
    }
    
    // MARK: - Public Methods
    

    

    

    
    func cleanDuplicates() {
        guard let result = scanResult else { return }
        
        cleanImagesUseCase.cleanDuplicates(result.duplicateGroups)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                         break // Cleaning completed
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
                         break // Cleaning completed
                     case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    func clearScanResults() {
        stopProgressTimer() // Stop any running progress timer
        scanResult = nil
        errorMessage = nil
        scanSuccessMessage = nil
    }
    
    // MARK: - Private Methods
    

    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.scanSuccessMessage = nil
        }
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
        
        self.errorMessage = nil
        self.scanSuccessMessage = nil
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
        print("Scan completed successfully") // Debug log
        showScanSuccessMessage()
    }
    
    private func completeScanWithError(_ error: Error) {
        self.errorMessage = error.localizedDescription
    }
    
    private func handleScanValue(_ result: ScanResult) {
        print("Scan result received: \(result.duplicateGroups.count) duplicates, " +
              "\(result.temporaryImages.count) temporary")
        self.scanResult = result
    }
}

// MARK: - Computed Properties
extension ScanResultsViewModel {

    

    
    var hasSuggestions: Bool {
        guard let result = scanResult else { return false }
        return !result.duplicateGroups.isEmpty || !result.temporaryImages.isEmpty
    }
}
