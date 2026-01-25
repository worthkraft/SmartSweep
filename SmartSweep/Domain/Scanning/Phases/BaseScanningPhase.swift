//
//  BaseScanningPhase.swift
//  SmartSweep
//

import Combine
import Foundation

/// Base class providing common functionality for all scanning phases
open class BaseScanningPhase: ScanningPhaseProtocol {

    // MARK: - Properties

    public let phaseType: ScanningPhaseType

    private let progressSubject = CurrentValueSubject<Double, Never>(0.0)
    public var progressPublisher: AnyPublisher<Double, Never> {
        progressSubject.eraseToAnyPublisher()
    }

    private var isInterrupted = false
    public var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(phaseType: ScanningPhaseType) {
        self.phaseType = phaseType
    }

    // MARK: - Progress Reporting

    /// Call this to update progress during execution
    public func reportProgress(_ progress: Double) {
        let clampedProgress = min(max(progress, 0.0), 1.0)
        progressSubject.send(clampedProgress)
    }

    /// Mark phase as complete
    public func reportComplete() {
        progressSubject.send(1.0)
    }

    // MARK: - Interruption

    public func interrupt() {
        isInterrupted = true
        cancellables.removeAll()
    }

    public var shouldContinue: Bool {
        !isInterrupted
    }

    // MARK: - Abstract Methods (Override in Subclasses)

    open func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        fatalError("Subclasses must override execute(context:)")
    }

    open func canExecute(context: ScanningContext) -> Bool {
        true
    }
}
