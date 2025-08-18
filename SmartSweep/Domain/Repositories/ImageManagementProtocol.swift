//
//  ImageManagementProtocol.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine

// Import entities - Since they're in the same module, they should be available
// If build issues persist, the entities need to be properly exposed in the module

public protocol ImageManagementProtocol {
    func deleteImages(_ images: [SmartImage]) -> AnyPublisher<Void, Error>
    func getStorageInfo() -> AnyPublisher<StorageInfo, Error>
}
