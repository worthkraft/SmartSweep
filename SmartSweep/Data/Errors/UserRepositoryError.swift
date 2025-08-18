//
//  UserRepositoryError.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public enum UserRepositoryError: LocalizedError {
    case productNotFound
    case verificationFailed
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Produk tidak ditemukan"
        case .verificationFailed:
            return "Verifikasi pembelian gagal"
        case .unknown(let message):
            return message
        }
    }
}
