//
//  ImageAccessProtocol.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine

// Import entities - Since they're in the same module, they should be available
// If build issues persist, the entities need to be properly exposed in the module

public protocol ImageAccessProtocol {
    func requestPhotoLibraryAccess() -> AnyPublisher<Bool, Never>
    func fetchAllImages() -> AnyPublisher<[SmartImage], Error>
}
