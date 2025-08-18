//
//  StorageInfo.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public struct StorageInfo {
    public let totalSpace: Int64
    public let usedSpace: Int64
    public let availableSpace: Int64
    public let cleanableSpace: Int64
    
    public init(totalSpace: Int64, usedSpace: Int64, availableSpace: Int64, cleanableSpace: Int64) {
        self.totalSpace = totalSpace
        self.usedSpace = usedSpace
        self.availableSpace = availableSpace
        self.cleanableSpace = cleanableSpace
    }
    
    public var usagePercentage: Double {
        Double(usedSpace) / Double(totalSpace)
    }
    
    public var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
    }
    
    public var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
    }
    
    public var formattedCleanableSpace: String {
        ByteCountFormatter.string(fromByteCount: cleanableSpace, countStyle: .file)
    }
}
