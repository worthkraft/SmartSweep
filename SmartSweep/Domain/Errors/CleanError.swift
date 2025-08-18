//
//  CleanError.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public enum CleanError: LocalizedError {
    case scanLimitReached
    case permissionDenied
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .scanLimitReached:
            return "Batas pemindaian mingguan tercapai. Upgrade ke Premium untuk pemindaian unlimited."
        case .permissionDenied:
            return "Akses ke galeri foto ditolak. Silakan izinkan akses di Pengaturan."
        case .unknown(let message):
            return message
        }
    }
}
