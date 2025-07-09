//
//  User.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

struct User: Codable {
    let id: String
    var isPremium: Bool
    var scanCount: Int
    var lastScanDate: Date?
    var purchaseDate: Date?
    
    init() {
        self.id = UUID().uuidString
        self.isPremium = false
        self.scanCount = 0
        self.lastScanDate = nil
        self.purchaseDate = nil
    }
    
    var canPerformDeepScan: Bool {
        if isPremium { return true }
        
        guard let lastScan = lastScanDate else { return true }
        
        let daysSinceLastScan = Calendar.current.dateComponents([.day], from: lastScan, to: Date()).day ?? 0
        return daysSinceLastScan >= 7 // Free tier: 1 deep scan per week
    }
    
    var maxImagesPerScan: Int {
        isPremium ? Int.max : 100
    }
}
