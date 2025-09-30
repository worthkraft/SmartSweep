//
//  ScanningViewModel.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 9/14/25.
//

import Foundation
import Combine
import SwiftUI

public class ScanningViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var currentTask: String = "Initializing..."
    @Published var isScanning: Bool = false
    @Published var scanResult: ScanResult?
    @Published var errorMessage: String?
    @Published var isCompleted: Bool = false
    
    private let cleanImagesUseCase: CleanImagesUseCase
    private let imageRepository: ImageRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var progressTimer: Timer?
    
    // Scanning phases with realistic timing
    private let scanningPhases = [
        (task: "Accessing photo library...", duration: 1.0, progressRange: 0.0...0.1),
        (task: "Gathering images...", duration: 2.0, progressRange: 0.1...0.3),
        (task: "Analyzing image properties...", duration: 3.0, progressRange: 0.3...0.5),
        (task: "Detecting duplicates...", duration: 4.0, progressRange: 0.5...0.8),
        (task: "Identifying temporary files...", duration: 2.0, progressRange: 0.8...0.9),
        (task: "Finalizing results...", duration: 1.0, progressRange: 0.9...1.0)
    ]
    
    public init(cleanImagesUseCase: CleanImagesUseCase, imageRepository: ImageRepositoryProtocol) {
        self.cleanImagesUseCase = cleanImagesUseCase
        self.imageRepository = imageRepository
    }
    
    public func startScanning() {
        guard !isScanning else { return }
        
        isScanning = true
        progress = 0.0
        isCompleted = false
        errorMessage = nil
        scanResult = nil
        
        // Start realistic progress animation
        startProgressAnimation()
        
        // Perform actual scanning
        cleanImagesUseCase.performSmartScan()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.completeScan()
                    case .failure(let error):
                        self?.handleScanError(error)
                    }
                },
                receiveValue: { [weak self] result in
                    self?.scanResult = result
                }
            )
            .store(in: &cancellables)
    }
    
    private func startProgressAnimation() {
        var currentPhaseIndex = 0
        var phaseStartTime = Date()
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, currentPhaseIndex < self.scanningPhases.count else {
                timer.invalidate()
                // Immediately complete when all phases are done
                self?.completeScan()
                return
            }
            
            let currentPhase = self.scanningPhases[currentPhaseIndex]
            let elapsedTime = Date().timeIntervalSince(phaseStartTime)
            let phaseProgress = min(elapsedTime / currentPhase.duration, 1.0)
            
            // Update current task
            if self.currentTask != currentPhase.task {
                self.currentTask = currentPhase.task
            }
            
            // Calculate progress within the phase range
            let progressInRange = currentPhase.progressRange.lowerBound + 
                (currentPhase.progressRange.upperBound - currentPhase.progressRange.lowerBound) * phaseProgress
            
            self.progress = progressInRange
            
            // Move to next phase if current one is complete
            if phaseProgress >= 1.0 {
                currentPhaseIndex += 1
                phaseStartTime = Date()
                
                // If we've completed all phases, immediately trigger completion
                if currentPhaseIndex >= self.scanningPhases.count {
                    timer.invalidate()
                    self.completeScan()
                }
            }
        }
    }
    
    private func completeScan() {
        progressTimer?.invalidate()
        progress = 1.0
        currentTask = "Scan completed!"
        isScanning = false
        isCompleted = true
        
        // Immediate navigation to results - no delay
    }
    
    private func handleScanError(_ error: Error) {
        progressTimer?.invalidate()
        isScanning = false
        errorMessage = error.localizedDescription
        currentTask = "Scan failed"
    }
    
    public func resetScan() {
        progressTimer?.invalidate()
        progress = 0.0
        currentTask = "Ready to scan"
        isScanning = false
        isCompleted = false
        errorMessage = nil
        scanResult = nil
    }
    
    deinit {
        progressTimer?.invalidate()
        cancellables.removeAll()
    }
}

