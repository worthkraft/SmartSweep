//
//  PhaseStateUpdate.swift
//  SmartSweep
//

import Foundation

/// Emitted when a phase's state changes
public struct PhaseStateUpdate: Equatable, Sendable {
    public let phaseType: ScanningPhaseType
    public let state: PhaseState
    public let timestamp: Date

    public init(
        phaseType: ScanningPhaseType,
        state: PhaseState,
        timestamp: Date = Date()
    ) {
        self.phaseType = phaseType
        self.state = state
        self.timestamp = timestamp
    }
}
