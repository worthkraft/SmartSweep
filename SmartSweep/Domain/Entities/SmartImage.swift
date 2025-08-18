//
//  SmartImage.swift
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
