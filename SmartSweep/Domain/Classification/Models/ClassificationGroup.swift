//
//  ClassificationGroup.swift
//  SmartSweep
//

import Foundation

public struct ClassificationGroup: Identifiable, Equatable, Sendable {

    // MARK: - Properties

    public let id: UUID
    public let classificationType: ImageClassificationType
    public let images: [SmartImage]
    public let metadata: ClassificationMetadata
    public let createdAt: Date

    // MARK: - Computed Properties

    /// Total size of all images in this group
    public var totalSize: Int64 {
        images.reduce(0) { $0 + $1.fileSize }
    }

    /// Number of images in the group
    public var count: Int {
        images.count
    }

    /// Whether this group has multiple images (for grouped classifications)
    public var isMultiImage: Bool {
        images.count > 1
    }

    /// The image to keep (for grouped classifications like duplicates)
    /// Returns the most recent image by default
    public var imageToKeep: SmartImage? {
        guard classificationType.isGrouped else { return nil }
        return images.max { $0.creationDate < $1.creationDate }
    }

    /// Images that can be safely deleted
    public var deletableImages: [SmartImage] {
        if classificationType.isGrouped {
            guard let keep = imageToKeep else { return images }
            return images.filter { $0.id != keep.id }
        } else {
            return images
        }
    }

    /// Space that can be saved by deleting deletable images
    public var savableSpace: Int64 {
        deletableImages.reduce(0) { $0 + $1.fileSize }
    }

    /// First image for thumbnail display
    public var thumbnailImage: SmartImage? {
        images.first
    }

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        classificationType: ImageClassificationType,
        images: [SmartImage],
        metadata: ClassificationMetadata = .empty,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.classificationType = classificationType
        self.images = images
        self.metadata = metadata
        self.createdAt = createdAt
    }

    // MARK: - Factory Methods

    /// Create a group for non-grouped classifications (one image per group)
    public static func individual(
        type: ImageClassificationType,
        image: SmartImage,
        metadata: ClassificationMetadata = .empty
    ) -> ClassificationGroup {
        ClassificationGroup(
            classificationType: type,
            images: [image],
            metadata: metadata
        )
    }

    /// Create a group for grouped classifications (multiple images)
    public static func grouped(
        type: ImageClassificationType,
        images: [SmartImage],
        metadata: ClassificationMetadata = .empty
    ) -> ClassificationGroup {
        ClassificationGroup(
            classificationType: type,
            images: images,
            metadata: metadata
        )
    }

    /// Create from legacy DuplicateGroup
    public static func fromDuplicateGroup(_ duplicateGroup: DuplicateGroup) -> ClassificationGroup {
        ClassificationGroup(
            classificationType: .duplicate,
            images: duplicateGroup.images,
            metadata: .empty
        )
    }

    // MARK: - Equatable

    public static func == (lhs: ClassificationGroup, rhs: ClassificationGroup) -> Bool {
        lhs.id == rhs.id
    }
}
