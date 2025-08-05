//
//  ImageRepository.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Photos
import Combine
import CoreLocation
import SmartSweepCore
import SmartSweepDomain

public class ImageRepository: ImageRepositoryProtocol {
    private let photoLibrary = PHPhotoLibrary.shared()
    
    public func requestPhotoLibraryAccess() -> AnyPublisher<Bool, Never> {
        return Future { promise in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    promise(.success(status == .authorized))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func fetchAllImages() -> AnyPublisher<[SmartImage], Error> {
        return Future { promise in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            
            let assets = PHAsset.fetchAssets(with: fetchOptions)
            var images: [SmartImage] = []
            
            assets.enumerateObjects { asset, _, _ in
                let image = SmartImage(asset: asset)
                images.append(image)
            }
            
            promise(.success(images))
        }
        .eraseToAnyPublisher()
    }
    
    public func detectDuplicates(images: [SmartImage]) -> AnyPublisher<[DuplicateGroup], Error> {
        let detectUseCase = DetectDuplicatesUseCase(imageRepository: self)
        return detectUseCase.detectDuplicates(in: images)
    }
    
    public func detectTemporaryImages(images: [SmartImage]) -> AnyPublisher<[SmartImage], Error> {
        return Future { promise in
            let temporaryImages = images.filter { image in
                self.isTemporaryImage(image)
            }
            promise(.success(temporaryImages))
        }
        .eraseToAnyPublisher()
    }
    
    public func deleteImages(_ images: [SmartImage]) -> AnyPublisher<Void, Error> {
        return Future { promise in
            PHPhotoLibrary.shared().performChanges({
                let assets = images.map { $0.asset }
                PHAssetChangeRequest.deleteAssets(assets as NSArray)
            }, completionHandler: { success, error in
                if success {
                    promise(.success(()))
                } else {
                    promise(.failure(error ?? ImageRepositoryError.deletionFailed))
                }
            })
        }
        .eraseToAnyPublisher()
    }
    
    public func getStorageInfo() -> AnyPublisher<StorageInfo, Error> {
        return Future { promise in
            do {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let attributes = try FileManager.default.attributesOfFileSystem(forPath: documentDirectory.path)
                
                let totalSpace = attributes[.systemSize] as? Int64 ?? 0
                let freeSpace = attributes[.systemFreeSize] as? Int64 ?? 0
                let usedSpace = totalSpace - freeSpace
                
                // Estimate cleanable space (this would be calculated from scan results)
                let cleanableSpace: Int64 = 0
                
                let storageInfo = StorageInfo(
                    totalSpace: totalSpace,
                    usedSpace: usedSpace,
                    availableSpace: freeSpace,
                    cleanableSpace: cleanableSpace
                )
                
                promise(.success(storageInfo))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func isTemporaryImage(_ image: SmartImage) -> Bool {
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
}

enum ImageRepositoryError: LocalizedError {
    case deletionFailed
    case accessDenied
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .deletionFailed:
            return "Gagal menghapus gambar"
        case .accessDenied:
            return "Akses ditolak"
        case .unknown(let message):
            return message
        }
    }
}
