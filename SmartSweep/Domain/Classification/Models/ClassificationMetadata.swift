//
//  ClassificationMetadata.swift
//  SmartSweep
//

import Foundation

public struct ClassificationMetadata: Equatable, Codable, Sendable {

    // MARK: - Common Properties

    /// Confidence score (0.0 - 1.0) for ML-based classifications
    public let confidence: Double?

    /// Similarity score for duplicate/similar detection
    public let similarityScore: Double?

    /// Hash value for duplicate detection
    public let hashValue: String?

    /// Detection algorithm used
    public let algorithm: String?

    /// Additional custom data
    public let customData: [String: String]

    // MARK: - Initialization

    public init(
        confidence: Double? = nil,
        similarityScore: Double? = nil,
        hashValue: String? = nil,
        algorithm: String? = nil,
        customData: [String: String] = [:]
    ) {
        self.confidence = confidence
        self.similarityScore = similarityScore
        self.hashValue = hashValue
        self.algorithm = algorithm
        self.customData = customData
    }

    // MARK: - Convenience

    public static let empty = ClassificationMetadata()

    /// Create metadata for duplicate detection
    public static func duplicate(similarityScore: Double, hash: String) -> ClassificationMetadata {
        ClassificationMetadata(
            similarityScore: similarityScore,
            hashValue: hash,
            algorithm: "perceptual_hash"
        )
    }

    /// Create metadata for ML-based classification
    public static func mlBased(confidence: Double, model: String) -> ClassificationMetadata {
        ClassificationMetadata(
            confidence: confidence,
            algorithm: model
        )
    }

    /// Create metadata for temporary file detection
    public static func temporary(reason: String) -> ClassificationMetadata {
        ClassificationMetadata(
            customData: ["reason": reason]
        )
    }
}
