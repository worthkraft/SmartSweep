//
//  User.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public struct User: Codable {
    public let id: String
    public var isPremium: Bool
    public var scanCount: Int
    public var lastScanDate: Date?
    public var purchaseDate: Date?
    
    public init() {
        self.id = UUID().uuidString
        self.isPremium = false
        self.scanCount = 0
        self.lastScanDate = nil
        self.purchaseDate = nil
    }
    
    public var canPerformDeepScan: Bool {
        if isPremium { return true }
        
        guard let lastScan = lastScanDate else { return true }
        
        let daysSinceLastScan = Calendar.current.dateComponents([.day], from: lastScan, to: Date()).day ?? 0
        return daysSinceLastScan >= 7 // Free tier: 1 deep scan per week
    }
    
    public var maxImagesPerScan: Int {
        isPremium ? Int.max : 100
    }
}
