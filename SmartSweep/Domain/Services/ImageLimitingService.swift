//
//  ImageLimitingService.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 15/1/26.
//

import Foundation

/// Handles image limiting logic based on user tier and permissions
public class ImageLimitingService {
    
    public init() {}
    
    /// Applies image limit based on user's premium status and scan limits
    /// - Parameters:
    ///   - images: All available images
    ///   - user: The user performing the scan
    /// - Returns: Limited array of images based on user's tier
    public func applyLimit(to images: [SmartImage], for user: User) -> [SmartImage] {
        if user.isPremium {
            return images
        } else {
            return Array(images.prefix(user.maxImagesPerScan))
        }
    }
}
