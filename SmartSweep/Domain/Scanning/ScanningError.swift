//
//  ScanningError.swift
//  SmartSweep
//

import Foundation

public enum ScanningError: LocalizedError {
    case handlerDeallocated
    case phaseNotRegistered(ScanningPhaseType)
    case phaseFailed(phaseType: ScanningPhaseType, reason: String)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .handlerDeallocated:
            return "Scanning handler was deallocated"
        case .phaseNotRegistered(let phaseType):
            return "Phase not registered: \(phaseType.displayName)"
        case .phaseFailed(let phaseType, let reason):
            return "\(phaseType.displayName) failed: \(reason)"
        case .cancelled:
            return "Scanning was cancelled"
        }
    }
}
