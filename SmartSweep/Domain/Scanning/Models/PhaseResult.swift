//
//  PhaseResult.swift
//  SmartSweep
//

import Foundation

/// Result of a single phase execution
public struct PhaseResult: Sendable {
    public let success: Bool
    public let message: String?
    public let shouldContinue: Bool

    public init(
        success: Bool = true,
        message: String? = nil,
        shouldContinue: Bool = true
    ) {
        self.success = success
        self.message = message
        self.shouldContinue = shouldContinue
    }

    public static let success = PhaseResult(success: true)
    public static let cancelled = PhaseResult(success: false, shouldContinue: false)
}
