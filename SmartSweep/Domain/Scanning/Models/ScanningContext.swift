//
//  ScanningContext.swift
//  SmartSweep
//

import Foundation

/// Shared mutable context passed through all scanning phases
public final class ScanningContext: @unchecked Sendable {

    // MARK: - Input

    public let user: User

    // MARK: - Accumulated Results

    public var images: [SmartImage] = []
    public var duplicateGroups: [DuplicateGroup] = []
    public var temporaryImages: [SmartImage] = []
    public var storageInfo: StorageInfo?

    // MARK: - Extensible Metadata

    public var metadata: [String: Any] = [:]

    // MARK: - Cancellation

    public private(set) var isCancelled: Bool = false

    public func cancel() {
        isCancelled = true
    }

    // MARK: - Initialization

    public init(user: User) {
        self.user = user
    }

    // MARK: - Conversion

    public func toScanResult() -> ScanResult {
        ScanResult(
            duplicateGroups: duplicateGroups,
            temporaryImages: temporaryImages,
            storageInfo: storageInfo ?? StorageInfo(
                totalSpace: 0,
                usedSpace: 0,
                availableSpace: 0,
                cleanableSpace: 0
            ),
            isWatermarked: !user.isPremium
        )
    }
}
