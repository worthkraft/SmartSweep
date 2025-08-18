//
//  UserPolicyService.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public protocol UserPolicyServiceProtocol {
    func canAccessFeature(_ feature: PremiumFeature, for user: User) -> Bool
    func getMaxImagesPerScan(for user: User) -> Int
    func canPerformDeepScan(for user: User) -> Bool
}

public class UserPolicyService: UserPolicyServiceProtocol {
    
    public init() {}
    
    public func canAccessFeature(_ feature: PremiumFeature, for user: User) -> Bool {
        guard user.isPremium else { return false }
        return true
    }
    
    public func getMaxImagesPerScan(for user: User) -> Int {
        return user.isPremium ? Int.max : 100
    }
    
    public func canPerformDeepScan(for user: User) -> Bool {
        if user.isPremium { return true }
        
        guard let lastScan = user.lastScanDate else { return true }
        
        let daysSinceLastScan = Calendar.current.dateComponents([.day], from: lastScan, to: Date()).day ?? 0
        return daysSinceLastScan >= 7 // Free tier: 1 deep scan per week
    }
}
