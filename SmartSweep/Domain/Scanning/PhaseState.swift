//
//  PhaseState.swift
//  SmartSweep
//

import Foundation

/// Represents the current state of a scanning phase
public enum PhaseState: Equatable, Sendable {
    /// Phase has not started yet
    case idle

    /// Phase has just started execution
    case started

    /// Phase is actively running with progress (0.0 - 1.0)
    case inProgress(progress: Double)

    /// Phase completed successfully
    case finished

    /// Phase was interrupted (e.g., user cancelled)
    case interrupted

    /// Phase failed with an error
    case failed(error: String)

    // MARK: - Computed Properties

    /// Whether the phase is currently active (started or in progress)
    public var isActive: Bool {
        switch self {
        case .started, .inProgress:
            return true
        default:
            return false
        }
    }

    /// Current progress value (0.0 - 1.0)
    public var progress: Double {
        switch self {
        case .idle, .started:
            return 0.0
        case .inProgress(let progress):
            return progress
        case .finished:
            return 1.0
        case .interrupted, .failed:
            return 0.0
        }
    }

    /// Whether this is a terminal state (no more updates expected)
    public var isTerminal: Bool {
        switch self {
        case .finished, .interrupted, .failed:
            return true
        default:
            return false
        }
    }

    /// Whether the phase completed successfully
    public var isSuccess: Bool {
        self == .finished
    }

    // MARK: - Equatable

    public static func == (lhs: PhaseState, rhs: PhaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.started, .started):
            return true
        case (.inProgress(let p1), .inProgress(let p2)):
            return p1 == p2
        case (.finished, .finished):
            return true
        case (.interrupted, .interrupted):
            return true
        case (.failed(let e1), .failed(let e2)):
            return e1 == e2
        default:
            return false
        }
    }
}
