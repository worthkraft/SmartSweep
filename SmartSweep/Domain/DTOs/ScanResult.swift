//
//  ScanResult.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public struct ScanResult: Equatable {

    // MARK: - Legacy Properties (Backward Compatibility)

    public let duplicateGroups: [DuplicateGroup]
    public let temporaryImages: [SmartImage]
    public let storageInfo: StorageInfo
    public let isWatermarked: Bool

    // MARK: - New Unified Classification Result

    public let classificationResult: ClassificationResult

    // MARK: - Legacy Computed Properties

    public var totalCleanableSpace: Int64 {
        let duplicateSpace = duplicateGroups.reduce(0) { $0 + $1.savableSpace }
        let temporarySpace = temporaryImages.reduce(0) { $0 + $1.fileSize }
        return duplicateSpace + temporarySpace
    }

    public var duplicateCount: Int {
        duplicateGroups.reduce(0) { $0 + $1.duplicatesToDelete.count }
    }

    public var temporaryCount: Int {
        temporaryImages.count
    }

    // MARK: - New Unified Computed Properties

    /// Total cleanable space from classification result
    public var totalSavableSpace: Int64 {
        classificationResult.totalSavableSpace
    }

    /// All available classification types with results
    public var availableClassificationTypes: [ImageClassificationType] {
        classificationResult.availableTypes
    }

    /// Check if scan found any cleanable items
    public var hasCleanableItems: Bool {
        !classificationResult.isEmpty || !duplicateGroups.isEmpty || !temporaryImages.isEmpty
    }

    // MARK: - Initialization

    public init(
        duplicateGroups: [DuplicateGroup],
        temporaryImages: [SmartImage],
        storageInfo: StorageInfo,
        isWatermarked: Bool,
        classificationResult: ClassificationResult = .empty
    ) {
        self.duplicateGroups = duplicateGroups
        self.temporaryImages = temporaryImages
        self.storageInfo = storageInfo
        self.isWatermarked = isWatermarked

        // If classificationResult is empty, populate from legacy data
        if classificationResult.isEmpty && (!duplicateGroups.isEmpty || !temporaryImages.isEmpty) {
            self.classificationResult = ClassificationResult.fromLegacy(
                duplicateGroups: duplicateGroups,
                temporaryImages: temporaryImages
            )
        } else {
            self.classificationResult = classificationResult
        }
    }

    // MARK: - Convenience Methods

    /// Get groups for a specific classification type
    public func groups(for type: ImageClassificationType) -> [ClassificationGroup] {
        classificationResult.groups(for: type)
    }

    /// Get count for a specific classification type
    public func count(for type: ImageClassificationType) -> Int {
        classificationResult.count(for: type)
    }

    /// Get image count for a specific classification type
    public func imageCount(for type: ImageClassificationType) -> Int {
        classificationResult.imageCount(for: type)
    }

    // MARK: - Equatable

    public static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        lhs.duplicateGroups.count == rhs.duplicateGroups.count &&
        lhs.temporaryImages.count == rhs.temporaryImages.count &&
        lhs.isWatermarked == rhs.isWatermarked
    }
}
