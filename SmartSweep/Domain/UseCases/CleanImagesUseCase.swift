//
//  CleanImagesUseCase.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine

public class CleanImagesUseCase {
    private let imageRepository: ImageRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(imageRepository: ImageRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.imageRepository = imageRepository
        self.userRepository = userRepository
    }
    
    public func performSmartScan() -> AnyPublisher<ScanResult, Error> {
        return userRepository.getCurrentUser()
            .tryMap { $0 }
            .flatMap { user -> AnyPublisher<ScanResult, Error> in
                guard user.canPerformDeepScan else {
                    return Fail(error: CleanError.scanLimitReached)
                        .eraseToAnyPublisher()
                }
                
                return self.imageRepository.fetchAllImages()
                    .map { images in
                        let limitedImages = user.isPremium ? images : Array(images.prefix(user.maxImagesPerScan))
                        return limitedImages
                    }
                    .tryMap { $0 }
                    .flatMap { images -> AnyPublisher<ScanResult, Error> in
                        let duplicatesPublisher = self.imageRepository.detectDuplicates(images: images)
                        let temporaryPublisher = self.imageRepository.detectTemporaryImages(images: images)
                        let storagePublisher = self.imageRepository.getStorageInfo()
                        
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
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    public func cleanDuplicates(_ groups: [DuplicateGroup]) -> AnyPublisher<Void, Error> {
        let imagesToDelete = groups.flatMap { $0.duplicatesToDelete }
        return imageRepository.deleteImages(imagesToDelete)
    }
    
    public func cleanTemporaryImages(_ images: [SmartImage]) -> AnyPublisher<Void, Error> {
        return imageRepository.deleteImages(images)
    }
}
