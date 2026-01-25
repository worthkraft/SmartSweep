//
//  ScanningPhaseProtocol.swift
//  SmartSweep
//

import Combine
import Foundation

/// Represents a single phase in the scanning process
public protocol ScanningPhaseProtocol: AnyObject {
    /// The type of this phase (enum-based identification)
    var phaseType: ScanningPhaseType { get }

    /// Publisher for progress updates within this phase (0.0 - 1.0)
    var progressPublisher: AnyPublisher<Double, Never> { get }

    /// Execute the phase with the given context
    /// - Parameter context: Shared scanning context
    /// - Returns: Publisher emitting PhaseResult on completion
    func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error>

    /// Check if phase can execute given current context
    func canExecute(context: ScanningContext) -> Bool

    /// Interrupt the phase execution (for cancellation)
    func interrupt()
}

// MARK: - Default Implementations

public extension ScanningPhaseProtocol {
    func canExecute(context: ScanningContext) -> Bool {
        true
    }

    func interrupt() {
        // Default: no-op, subclasses can override
    }
}
