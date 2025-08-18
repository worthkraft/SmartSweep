//
//  ScanResult.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public struct ScanResult {
    public let duplicateGroups: [DuplicateGroup]
    public let temporaryImages: [SmartImage]
    public let storageInfo: StorageInfo
    public let isWatermarked: Bool
    
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
    
    public init(duplicateGroups: [DuplicateGroup],
                temporaryImages: [SmartImage],
                storageInfo: StorageInfo,
                isWatermarked: Bool) {
        self.duplicateGroups = duplicateGroups
        self.temporaryImages = temporaryImages
        self.storageInfo = storageInfo
        self.isWatermarked = isWatermarked
    }
}
