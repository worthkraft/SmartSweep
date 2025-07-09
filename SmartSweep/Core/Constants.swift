//
//  Constants.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import SwiftUI

struct AppConstants {
    // MARK: - Colors
    struct Colors {
        static let primary = Color(red: 42/255, green: 183/255, blue: 202/255) // #2AB7CA
        static let background = Color.white
        static let textPrimary = Color(red: 74/255, green: 74/255, blue: 74/255) // #4A4A4A
        static let textSecondary = Color.gray
        static let cardBackground = Color(.systemGray6)
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
    }
    
    // MARK: - Strings
    struct Strings {
        static let appName = "SmartSweep"
        static let smartScan = "SMART SCAN"
        static let cleanNow = "Bersihkan Sekarang"
        static let review = "Tinjau"
        static let premium = "Premium"
        static let duplicates = "Duplikat"
        static let temporaryImages = "Gambar Sementara"
        static let screenshots = "Screenshot"
        static let settings = "Pengaturan"
        static let storage = "Penyimpanan"
        static let cleanable = "Dapat Dibersihkan"
        static let scanning = "Memindai..."
        static let completed = "Selesai"
        static let upgrade = "Upgrade ke Premium"
    }
    
    // MARK: - Pricing
    struct Pricing {
        static let premiumPrice = "Rp 99.000"
        static let promoPrice = "Rp 49.000"
        static let productID = "com.smartsweep.premium"
    }
    
    // MARK: - Limits
    struct Limits {
        static let freeMaxImages = 100
        static let freeScanCooldownDays = 7
    }
    
    // MARK: - Animation
    struct Animation {
        static let buttonPress = SwiftUI.Animation.easeInOut(duration: 0.1)
        static let scanPulse = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        static let progressBar = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
}
