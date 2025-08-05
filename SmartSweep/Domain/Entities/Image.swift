//
//  Image.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Photos
import CoreLocation

public struct SmartImage: Identifiable, Hashable {
    public let id: String
    public let asset: PHAsset
    public let creationDate: Date
    public let fileSize: Int64
    public let filename: String
    public let location: CLLocation?
    public let isScreenshot: Bool
    public let isDuplicate: Bool
    public let isTemporary: Bool
    public let duplicateGroup: String?
    
    public init(asset: PHAsset) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.creationDate = asset.creationDate ?? Date()
        self.fileSize = Int64(asset.pixelWidth * asset.pixelHeight * 4) // Approximate
        self.filename = asset.value(forKey: "filename") as? String ?? "Unknown"
        self.location = asset.location
        self.isScreenshot = asset.mediaSubtypes.contains(.photoScreenshot)
        self.isDuplicate = false // Will be calculated
        self.isTemporary = false // Will be calculated
        self.duplicateGroup = nil
    }
    
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}

public struct DuplicateGroup: Identifiable {
    public let id = UUID()
    public let images: [SmartImage]
    public let totalSize: Int64
    
    public var keepImage: SmartImage? {
        images.max { $0.creationDate < $1.creationDate }
    }
    
    var duplicatesToDelete: [SmartImage] {
        guard let keep = keepImage else { return images }
        return images.filter { $0.id != keep.id }
    }
    
    public var savableSpace: Int64 {
        duplicatesToDelete.reduce(0) { $0 + $1.fileSize }
    }
}

public struct StorageInfo {
    public let totalSpace: Int64
    public let usedSpace: Int64
    public let availableSpace: Int64
    public let cleanableSpace: Int64
    
    public init(totalSpace: Int64, usedSpace: Int64, availableSpace: Int64, cleanableSpace: Int64) {
        self.totalSpace = totalSpace
        self.usedSpace = usedSpace
        self.availableSpace = availableSpace
        self.cleanableSpace = cleanableSpace
    }
    
    public var usagePercentage: Double {
        Double(usedSpace) / Double(totalSpace)
    }
    
    public var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
    }
    
    public var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
    }
    
    public var formattedCleanableSpace: String {
        ByteCountFormatter.string(fromByteCount: cleanableSpace, countStyle: .file)
    }
}

public enum ScanStatus: Equatable {
    case idle
    case scanning
    case completed
    case error(String)
    
    public static func == (lhs: ScanStatus, rhs: ScanStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.scanning, .scanning): return true
        case (.completed, .completed): return true
        case (.error(let leftMessage), .error(let rightMessage)): return leftMessage == rightMessage
        default: return false
        }
    }
}

enum PremiumFeature {
    case screenshotFiltering
    case unlimitedScans
    case watermarkRemoval
    case advancedDuplicateDetection
}
