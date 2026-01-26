//
//  ScanningViewModel.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 9/14/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
public class ScanningViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var overallProgress: Double = 0.0
    @Published var currentTask: String = "Initializing..."
    @Published var isScanning: Bool = false
    @Published var scanResult: ScanResult?
    @Published var errorMessage: String?
    @Published var isCompleted: Bool = false

    /// State for each phase bubble
    @Published var phaseStates: [ScanningPhaseType: PhaseState] = [:]

    // MARK: - Dependencies

    private let scanningHandler: ScanningHandler
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var enabledPhases: [ScanningPhaseType] {
        scanningHandler.phases
    }

    var phaseInfoList: [PhaseInfo] {
        scanningHandler.phaseInfoList
    }

    // MARK: - Initialization

    public init(scanningHandler: ScanningHandler) {
        self.scanningHandler = scanningHandler
        setupStateSubscription()
        initializePhaseStates()
    }

    // MARK: - Public Methods

    public func startScanning() {
        guard !isScanning else { return }

        isScanning = true
        overallProgress = 0.0
        isCompleted = false
        errorMessage = nil
        scanResult = nil
        initializePhaseStates()

        scanningHandler.startScan()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .finished:
                        self.completeScan()
                    case .failure(let error):
                        self.handleScanError(error)
                    }
                },
                receiveValue: { [weak self] result in
                    guard let self = self else { return }
                    self.scanResult = result
                    // Also trigger completion when we receive the result
                    // This ensures navigation happens even if receiveCompletion has issues
                    self.completeScan()
                }
            )
            .store(in: &cancellables)
    }

    public func cancelScan() {
        scanningHandler.cancelScan()
        resetScan()
    }

    public func resetScan() {
        overallProgress = 0.0
        currentTask = "Ready to scan"
        isScanning = false
        isCompleted = false
        errorMessage = nil
        scanResult = nil
        initializePhaseStates()
    }

    // MARK: - Private Methods

    private func setupStateSubscription() {
        scanningHandler.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.handlePhaseStateUpdate(update)
            }
            .store(in: &cancellables)
    }

    private func initializePhaseStates() {
        enabledPhases.forEach { phaseType in
            phaseStates[phaseType] = .idle
        }
    }

    private func handlePhaseStateUpdate(_ update: PhaseStateUpdate) {
        // Update phase state
        phaseStates[update.phaseType] = update.state

        // Update current task text
        if update.state.isActive {
            currentTask = update.phaseType.displayName
        } else if update.state == .finished {
            // Find next phase for task text
            if let nextPhase = enabledPhases.first(where: {
                (phaseStates[$0] ?? .idle) == .idle
            }) {
                currentTask = "Preparing \(nextPhase.displayName)"
            }
        }

        // Update overall progress
        updateOverallProgress()
    }

    private func updateOverallProgress() {
        let phaseInfos = phaseInfoList
        var totalProgress: Double = 0.0

        for phaseInfo in phaseInfos {
            let phaseType = phaseInfo.phaseType
            let state = phaseStates[phaseType] ?? .idle
            let phaseRange = phaseInfo.progressRange
            let rangeSize = phaseRange.upperBound - phaseRange.lowerBound

            switch state {
            case .finished:
                totalProgress = phaseRange.upperBound
            case .inProgress(let progress):
                totalProgress = phaseRange.lowerBound + (rangeSize * progress)
            case .started:
                totalProgress = phaseRange.lowerBound
            default:
                break
            }
        }

        overallProgress = min(totalProgress, 1.0)
    }

    private func completeScan() {
        // Prevent double completion
        guard !isCompleted else { return }

        overallProgress = 1.0
        currentTask = "Scan completed!"
        isScanning = false
        isCompleted = true
    }

    private func handleScanError(_ error: Error) {
        isScanning = false
        errorMessage = error.localizedDescription
        currentTask = "Scan failed"
    }
}

