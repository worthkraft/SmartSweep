//
//  ScanStatus.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public enum ScanStatus: Equatable {
    case idle
    case scanning
    case completed
    case error(String)
    
    public static func == (lhs: ScanStatus, rhs: ScanStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.scanning, .scanning): return true
        case (.completed, .completed): return true
        case (.error(let leftMessage), .error(let rightMessage)): return leftMessage == rightMessage
        default: return false
        }
    }
}
