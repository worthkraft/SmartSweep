//
//  ImageAnalysisService.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public protocol ImageAnalysisServiceProtocol {
    func isTemporaryImage(_ image: SmartImage) -> Bool
    func analyzeStorageUsage(images: [SmartImage]) -> StorageAnalysis
}

public struct StorageAnalysis {
    public let totalImages: Int
    public let totalSize: Int64
    public let temporaryImages: [SmartImage]
    public let duplicateGroups: [DuplicateGroup]
    
    public init(totalImages: Int, totalSize: Int64, temporaryImages: [SmartImage], duplicateGroups: [DuplicateGroup]) {
        self.totalImages = totalImages
        self.totalSize = totalSize
        self.temporaryImages = temporaryImages
        self.duplicateGroups = duplicateGroups
    }
}

public class ImageAnalysisService: ImageAnalysisServiceProtocol {
    
    public init() {}
    
    public func isTemporaryImage(_ image: SmartImage) -> Bool {
        let filename = image.filename.lowercased()
        
        // Check for payment confirmation patterns
        let paymentKeywords = ["payment", "receipt", "invoice", "bill", "transfer", "qr", "barcode"]
        let hasPaymentKeyword = paymentKeywords.contains { filename.contains($0) }
        
        // Check for location share patterns  
        let locationKeywords = ["location", "maps", "coordinate", "pin"]
        let hasLocationKeyword = locationKeywords.contains { filename.contains($0) }
        
        // Check for temporary patterns
        let tempKeywords = ["temp", "tmp", "cache", "whatsapp"]
        let hasTempKeyword = tempKeywords.contains { filename.contains($0) }
        
        // Check creation date (images from last 3 days that match patterns)
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: image.creationDate, to: Date()).day ?? 0
        let isRecent = daysSinceCreation <= 3
        
        return isRecent && (hasPaymentKeyword || hasLocationKeyword || hasTempKeyword)
    }
    
    public func analyzeStorageUsage(images: [SmartImage]) -> StorageAnalysis {
        let totalSize = images.reduce(0) { $0 + $1.fileSize }
        let temporaryImages = images.filter { isTemporaryImage($0) }
        
        return StorageAnalysis(
            totalImages: images.count,
            totalSize: totalSize,
            temporaryImages: temporaryImages,
            duplicateGroups: []
        )
    }
}
