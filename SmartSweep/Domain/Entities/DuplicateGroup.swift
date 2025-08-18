//
//  DuplicateGroup.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public struct DuplicateGroup: Identifiable {
    public let id = UUID()
    public let images: [SmartImage]
    public let totalSize: Int64
    
    public var keepImage: SmartImage? {
        images.max { $0.creationDate < $1.creationDate }
    }
    
    public var duplicatesToDelete: [SmartImage] {
        guard let keep = keepImage else { return images }
        return images.filter { $0.id != keep.id }
    }
    
    public var savableSpace: Int64 {
        duplicatesToDelete.reduce(0) { $0 + $1.fileSize }
    }
}
