//
//  ImageRepositoryError.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public enum ImageRepositoryError: LocalizedError {
    case deletionFailed
    case accessDenied
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .deletionFailed:
            return "Gagal menghapus gambar"
        case .accessDenied:
            return "Akses ditolak"
        case .unknown(let message):
            return message
        }
    }
}
