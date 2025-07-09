//
//  Image.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Photos
import CoreLocation

struct SmartImage: Identifiable, Hashable {
    let id: String
    let asset: PHAsset
    let creationDate: Date
    let fileSize: Int64
    let filename: String
    let location: CLLocation?
    let isScreenshot: Bool
    let isDuplicate: Bool
    let isTemporary: Bool
    let duplicateGroup: String?
    
    init(asset: PHAsset) {
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

struct DuplicateGroup: Identifiable {
    let id = UUID()
    let images: [SmartImage]
    let totalSize: Int64
    
    var keepImage: SmartImage? {
        images.max { $0.creationDate < $1.creationDate }
    }
    
    var duplicatesToDelete: [SmartImage] {
        guard let keep = keepImage else { return images }
        return images.filter { $0.id != keep.id }
    }
    
    var savableSpace: Int64 {
        duplicatesToDelete.reduce(0) { $0 + $1.fileSize }
    }
}

struct StorageInfo {
    let totalSpace: Int64
    let usedSpace: Int64
    let availableSpace: Int64
    let cleanableSpace: Int64
    
    var usagePercentage: Double {
        Double(usedSpace) / Double(totalSpace)
    }
    
    var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
    }
    
    var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
    }
    
    var formattedCleanableSpace: String {
        ByteCountFormatter.string(fromByteCount: cleanableSpace, countStyle: .file)
    }
}

enum ScanStatus: Equatable {
    case idle
    case scanning
    case completed
    case error(String)
    
    static func == (lhs: ScanStatus, rhs: ScanStatus) -> Bool {
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
