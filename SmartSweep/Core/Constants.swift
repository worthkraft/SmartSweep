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
        public static let primary = Color(red: 42 / 255, green: 183 / 255, blue: 202 / 255) // #2AB7CA
        public static let background = Color.white
        public static let textPrimary = Color(red: 74 / 255, green: 74 / 255, blue: 74 / 255) // #4A4A4A
        public static let textSecondary = Color.gray
        public static let cardBackground = Color(.systemGray6)
        public static let success = Color.green
        public static let warning = Color.orange
        public static let error = Color.red
        
        // MARK: - Dark Theme Colors
        public static let backgroundDarkTop = Color(red: 13 / 255, green: 14 / 255, blue: 16 / 255) // #0D0E10
        public static let backgroundDarkBottom = Color(red: 17 / 255, green: 18 / 255, blue: 23 / 255) // #111217
        public static let accentPinkStart = Color(red: 255 / 255, green: 42 / 255, blue: 109 / 255) // #FF2A6D
        public static let accentPinkEnd = Color(red: 255 / 255, green: 126 / 255, blue: 134 / 255) // #FF7E86
        public static let cardSurface = Color(red: 23 / 255, green: 24 / 255, blue: 28 / 255) // #17181C
        public static let textPrimaryDark = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255) // #FFFFFF
        public static let textSecondaryDark = Color(red: 207 / 255, green: 207 / 255, blue: 211 / 255) // #CFCFD3
    }
    
    // MARK: - Strings
    public struct Strings {
        public static let appName = "SmartSweep"
        public static let smartScan = "SMART SCAN"
        public static let smartClean = "Smart Clean"
        public static let cleanNow = "Bersihkan Sekarang"
        public static let review = "Tinjau"
        public static let premium = "Premium"
        public static let duplicates = "Duplikat"
        public static let temporaryImages = "Gambar Sementara"
        public static let screenshots = "Screenshot"
        public static let settings = "Pengaturan"
        public static let storage = "Penyimpanan"
        public static let cleanable = "Dapat Dibersihkan"
        public static let scanning = "Memindai..."
        public static let completed = "Selesai"
        public static let upgrade = "Upgrade ke Premium"
        public static let storageHint = "Clean your storage to reclaim free space"
        public static let usedLabel = "Used"
        public static let ofLabel = "of"
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
        public static let freeScanCooldownDays = 7
    }
    
    // MARK: - Animation
    public struct Animation {
        public static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        public static let scanPulse = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        public static let progressBar = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
    
    // MARK: - Typography
    public struct Typography {
        public static let titleBold = Font.system(size: 28, weight: .bold, design: .rounded)
        public static let headlineBold = Font.system(size: 22, weight: .bold, design: .rounded)
        public static let bodyMedium = Font.system(size: 16, weight: .medium, design: .rounded)
        public static let captionMedium = Font.system(size: 14, weight: .medium, design: .rounded)
        public static let smallMedium = Font.system(size: 12, weight: .medium, design: .rounded)
    }
}
