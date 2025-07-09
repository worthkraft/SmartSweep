//
//  CleanImagesUseCase.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine

class CleanImagesUseCase {
    private let imageRepository: ImageRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(imageRepository: ImageRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.imageRepository = imageRepository
        self.userRepository = userRepository
    }
    
    func performSmartScan() -> AnyPublisher<ScanResult, Error> {
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
    
    func cleanDuplicates(_ groups: [DuplicateGroup]) -> AnyPublisher<Void, Error> {
        let imagesToDelete = groups.flatMap { $0.duplicatesToDelete }
        return imageRepository.deleteImages(imagesToDelete)
    }
    
    func cleanTemporaryImages(_ images: [SmartImage]) -> AnyPublisher<Void, Error> {
        return imageRepository.deleteImages(images)
    }
}

struct ScanResult {
    let duplicateGroups: [DuplicateGroup]
    let temporaryImages: [SmartImage]
    let storageInfo: StorageInfo
    let isWatermarked: Bool
    
    var totalCleanableSpace: Int64 {
        let duplicateSpace = duplicateGroups.reduce(0) { $0 + $1.savableSpace }
        let temporarySpace = temporaryImages.reduce(0) { $0 + $1.fileSize }
        return duplicateSpace + temporarySpace
    }
    
    var duplicateCount: Int {
        duplicateGroups.reduce(0) { $0 + $1.duplicatesToDelete.count }
    }
    
    var temporaryCount: Int {
        temporaryImages.count
    }
}

enum CleanError: LocalizedError {
    case scanLimitReached
    case permissionDenied
    case unknown(String)
    
    var errorDescription: String? {
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
