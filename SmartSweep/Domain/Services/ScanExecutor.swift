//
//  ScanExecutor.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 15/1/26.
//

import Foundation
import Combine

/// Executes the actual scan operations (duplicates, temporary images, storage info)
public class ScanExecutor {
    private let imageRepository: ImageRepositoryProtocol
    
    public init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
    }
    
    /// Executes a comprehensive scan on the provided images
    /// - Parameters:
    ///   - images: Images to scan
    ///   - user: User performing the scan (for watermark determination)
    /// - Returns: Publisher that emits a ScanResult
    public func execute(on images: [SmartImage], for user: User) -> AnyPublisher<ScanResult, Error> {
        let duplicatesPublisher = imageRepository.detectDuplicates(images: images)
        let temporaryPublisher = imageRepository.detectTemporaryImages(images: images)
        let storagePublisher = imageRepository.getStorageInfo()
        
        return Publishers.Zip3(duplicatesPublisher, temporaryPublisher, storagePublisher)
            .map { duplicates, temporary, storage in
                ScanResult(
                    duplicateGroups: duplicates,
                    temporaryImages: temporary,
                    storageInfo: storage,
                    isWatermarked: !user.isPremium
                )
            }
            .eraseToAnyPublisher()
    }
}
