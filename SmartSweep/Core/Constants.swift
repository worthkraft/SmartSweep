//
//  Constants.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import SwiftUI

public struct AppConstants {
    // MARK: - Colors
    public struct Colors {
        public static let primary = Color(red: 42/255, green: 183/255, blue: 202/255) // #2AB7CA
        public static let background = Color.white
        public static let textPrimary = Color(red: 74/255, green: 74/255, blue: 74/255) // #4A4A4A
        public static let textSecondary = Color.gray
        public static let cardBackground = Color(.systemGray6)
        public static let success = Color.green
        public static let warning = Color.orange
        public static let error = Color.red
    }
    
    // MARK: - Strings
    public struct Strings {
        public static let appName = "SmartSweep"
        public static let smartScan = "SMART SCAN"
        public static let cleanNow = "Bersihkan Sekarang"
        public static let review = "Tinjau"
        public static let premium = "Premium"
        public static let duplicates = "Duplikat"
        public static let temporaryImages = "Gambar Sementara"
        static let screenshots = "Screenshot"
        public static let settings = "Pengaturan"
        public static let storage = "Penyimpanan"
        public static let cleanable = "Dapat Dibersihkan"
        public static let scanning = "Memindai..."
        public static let completed = "Selesai"
        public static let upgrade = "Upgrade ke Premium"
    }
    
    // MARK: - Pricing
    public struct Pricing {
        public static let premiumPrice = "Rp 99.000"
        public static let promoPrice = "Rp 49.000"
        public static let productID = "com.smartsweep.premium"
    }
    
    // MARK: - Limits
    public struct Limits {
        public static let freeMaxImages = 100
        static let freeScanCooldownDays = 7
    }
    
    // MARK: - Animation
    public struct Animation {
        public static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        public static let scanPulse = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        public static let progressBar = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}
