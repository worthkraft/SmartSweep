//
//  CleanImagesUseCase.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine
import SmartSweepCore

public class CleanImagesUseCase {
    private let imageRepository: ImageRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    public init(imageRepository: ImageRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.imageRepository = imageRepository
        self.userRepository = userRepository
    }
    
    public func performSmartScan() -> AnyPublisher<ScanResult, Error> {
        return userRepository.getCurrentUser()
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

public enum CleanError: LocalizedError {
    case scanLimitReached
    case permissionDenied
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .scanLimitReached:
            return "Batas pemindaian mingguan tercapai. Upgrade ke Premium untuk pemindaian unlimited."
        case .permissionDenied:
            return "Akses ke galeri foto ditolak. Silakan izinkan akses di Pengaturan."
        case .unknown(let message):
            return message
        }
    }
}
