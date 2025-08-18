//
//  ImageProcessingProtocol.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine

// Import entities - Since they're in the same module, they should be available
// If build issues persist, the entities need to be properly exposed in the module

public protocol ImageProcessingProtocol {
    func detectDuplicates(images: [SmartImage]) -> AnyPublisher<[DuplicateGroup], Error>
    func detectTemporaryImages(images: [SmartImage]) -> AnyPublisher<[SmartImage], Error>
}
