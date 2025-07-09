//
//  ImageRepository.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Photos
import Combine

protocol ImageRepositoryProtocol {
    func requestPhotoLibraryAccess() -> AnyPublisher<Bool, Never>
    func fetchAllImages() -> AnyPublisher<[SmartImage], Error>
    func detectDuplicates(images: [SmartImage]) -> AnyPublisher<[DuplicateGroup], Error>
    func detectTemporaryImages(images: [SmartImage]) -> AnyPublisher<[SmartImage], Error>
    func deleteImages(_ images: [SmartImage]) -> AnyPublisher<Void, Error>
    func getStorageInfo() -> AnyPublisher<StorageInfo, Error>
}
