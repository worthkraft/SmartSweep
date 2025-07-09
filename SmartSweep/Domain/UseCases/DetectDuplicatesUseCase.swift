//
//  DetectDuplicatesUseCase.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine
import Vision
import UIKit
import Photos

class DetectDuplicatesUseCase {
    private let imageRepository: ImageRepositoryProtocol
    
    init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
    }
    
    func detectDuplicates(in images: [SmartImage]) -> AnyPublisher<[DuplicateGroup], Error> {
        return Future { promise in
            Task {
                do {
                    let groups = try await self.performDuplicateDetection(images: images)
                    promise(.success(groups))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func performDuplicateDetection(images: [SmartImage]) async throws -> [DuplicateGroup] {
        var imageHashes: [String: [SmartImage]] = [:]
        
        // First pass: Group by file size and creation date proximity
        let sizeGroups = Dictionary(grouping: images) { image in
            "\(image.fileSize)_\(Calendar.current.dateComponents([.year, .month, .day], from: image.creationDate))"
        }
        
        for (_, sizeGroup) in sizeGroups where sizeGroup.count > 1 {
            // Use Vision framework for visual similarity
            let similarImages = try await findVisuallyDuplicates(in: sizeGroup)
            
            for group in similarImages where group.count > 1 {
                let hashKey = UUID().uuidString
                imageHashes[hashKey] = group
            }
        }
        
        return imageHashes.values.map { duplicateImages in
            DuplicateGroup(
                images: duplicateImages,
                totalSize: duplicateImages.reduce(0) { $0 + $1.fileSize }
            )
        }
    }
    
    private func findVisuallyDuplicates(in images: [SmartImage]) async throws -> [[SmartImage]] {
        var imageFeatures: [(SmartImage, VNFeaturePrintObservation)] = []
        
        // Extract visual features for each image
        for image in images {
            if let feature = try await extractImageFeatures(from: image.asset) {
                imageFeatures.append((image, feature))
            }
        }
        
        // Group by visual similarity
        var duplicateGroups: [[SmartImage]] = []
        var processed: Set<String> = []
        
        for (currentImage, currentFeature) in imageFeatures {
            if processed.contains(currentImage.id) { continue }
            
            var currentGroup = [currentImage]
            processed.insert(currentImage.id)
            
            for (otherImage, otherFeature) in imageFeatures {
                if processed.contains(otherImage.id) { continue }
                
                var distance: Float = 0
                try currentFeature.computeDistance(&distance, to: otherFeature)
                
                // Threshold for considering images as duplicates (lower = more similar)
                if distance < 0.1 {
                    currentGroup.append(otherImage)
                    processed.insert(otherImage.id)
                }
            }
            
            if currentGroup.count > 1 {
                duplicateGroups.append(currentGroup)
            }
        }
        
        return duplicateGroups
    }
    
    private func extractImageFeatures(from asset: PHAsset) async throws -> VNFeaturePrintObservation? {
        return try await withCheckedThrowingContinuation { continuation in
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .highQualityFormat
            
            let targetSize = CGSize(width: 299, height: 299)
            manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                guard let image = image, let cgImage = image.cgImage else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let request = VNGenerateImageFeaturePrintRequest()
                let handler = VNImageRequestHandler(cgImage: cgImage)
                
                do {
                    try handler.perform([request])
                    if let observation = request.results?.first {
                        continuation.resume(returning: observation)
                    } else {
                        continuation.resume(returning: nil)
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
