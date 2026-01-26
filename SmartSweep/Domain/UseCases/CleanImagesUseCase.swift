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
    private let permissionValidator: ScanPermissionValidator
    private let imageLimitingService: ImageLimitingService
    private let scanExecutor: ScanExecutor
    
    public init(
        imageRepository: ImageRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        permissionValidator: ScanPermissionValidator,
        imageLimitingService: ImageLimitingService,
        scanExecutor: ScanExecutor
    ) {
        self.imageRepository = imageRepository
        self.userRepository = userRepository
        self.permissionValidator = permissionValidator
        self.imageLimitingService = imageLimitingService
        self.scanExecutor = scanExecutor
    }
    
    public func performSmartScan() -> AnyPublisher<ScanResult, Error> {
        return permissionValidator.validateScanPermission()
            .flatMap { user -> AnyPublisher<ScanResult, Error> in
                return self.imageRepository.fetchAllImages()
                    .map { images in
                        self.imageLimitingService.applyLimit(to: images, for: user)
                    }
                    .flatMap { limitedImages -> AnyPublisher<ScanResult, Error> in
                        self.scanExecutor.execute(on: limitedImages, for: user)
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
