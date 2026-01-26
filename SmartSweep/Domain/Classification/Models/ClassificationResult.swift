//
//  ClassificationResult.swift
//  SmartSweep
//

import Foundation

public struct ClassificationResult: Equatable, Sendable {

    // MARK: - Properties

    /// All classification groups indexed by type
    private var groupsByType: [ImageClassificationType: [ClassificationGroup]]

    /// Timestamp of when classification was completed
    public let completedAt: Date

    // MARK: - Computed Properties

    /// All classification types that have results
    public var availableTypes: [ImageClassificationType] {
        groupsByType.keys.sorted { $0.displayOrder < $1.displayOrder }
    }

    /// Total number of classification groups across all types
    public var totalGroupCount: Int {
        groupsByType.values.reduce(0) { $0 + $1.count }
    }

    /// Total number of images classified
    public var totalImageCount: Int {
        groupsByType.values.reduce(0) { total, groups in
            total + groups.reduce(0) { $0 + $1.count }
        }
    }

    /// Total space that can be saved
    public var totalSavableSpace: Int64 {
        groupsByType.values.reduce(0) { total, groups in
            total + groups.reduce(0) { $0 + $1.savableSpace }
        }
    }

    /// Check if results are empty
    public var isEmpty: Bool {
        totalGroupCount == 0
    }

    // MARK: - Initialization

    public init(
        groupsByType: [ImageClassificationType: [ClassificationGroup]] = [:],
        completedAt: Date = Date()
    ) {
        self.groupsByType = groupsByType
        self.completedAt = completedAt
    }

    /// Empty result
    public static let empty = ClassificationResult()

    // MARK: - Access Methods

    /// Get groups for a specific classification type
    public func groups(for type: ImageClassificationType) -> [ClassificationGroup] {
        groupsByType[type] ?? []
    }

    /// Get count for a specific classification type
    public func count(for type: ImageClassificationType) -> Int {
        groups(for: type).count
    }

    /// Get image count for a specific classification type
    public func imageCount(for type: ImageClassificationType) -> Int {
        groups(for: type).reduce(0) { $0 + $1.count }
    }

    /// Get savable space for a specific classification type
    public func savableSpace(for type: ImageClassificationType) -> Int64 {
        groups(for: type).reduce(0) { $0 + $1.savableSpace }
    }

    /// Check if a specific type has results
    public func hasResults(for type: ImageClassificationType) -> Bool {
        !groups(for: type).isEmpty
    }

    // MARK: - Mutation Methods

    /// Add groups for a classification type
    public mutating func add(groups: [ClassificationGroup], for type: ImageClassificationType) {
        var existing = groupsByType[type] ?? []
        existing.append(contentsOf: groups)
        groupsByType[type] = existing
    }

    /// Set groups for a classification type (replaces existing)
    public mutating func set(groups: [ClassificationGroup], for type: ImageClassificationType) {
        groupsByType[type] = groups
    }

    /// Remove all groups for a classification type
    public mutating func removeGroups(for type: ImageClassificationType) {
        groupsByType.removeValue(forKey: type)
    }

    /// Clear all results
    public mutating func clear() {
        groupsByType.removeAll()
    }

    // MARK: - Conversion

    /// Get all deletable images across all classification types
    public func allDeletableImages() -> [SmartImage] {
        groupsByType.values.flatMap { groups in
            groups.flatMap { $0.deletableImages }
        }
    }

    /// Get deletable images for a specific type
    public func deletableImages(for type: ImageClassificationType) -> [SmartImage] {
        groups(for: type).flatMap { $0.deletableImages }
    }

    // MARK: - Legacy Conversion

    /// Convert from legacy data structures
    public static func fromLegacy(
        duplicateGroups: [DuplicateGroup],
        temporaryImages: [SmartImage]
    ) -> ClassificationResult {
        var result = ClassificationResult()

        // Convert duplicate groups
        let duplicateClassificationGroups = duplicateGroups.map { legacyGroup in
            ClassificationGroup.fromDuplicateGroup(legacyGroup)
        }
        result.set(groups: duplicateClassificationGroups, for: .duplicate)

        // Convert temporary images (each as individual group)
        let temporaryClassificationGroups = temporaryImages.map { image in
            ClassificationGroup.individual(type: .temporary, image: image)
        }
        result.set(groups: temporaryClassificationGroups, for: .temporary)

        return result
    }
}
