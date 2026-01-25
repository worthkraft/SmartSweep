//
//  ScanningPhaseType.swift
//  SmartSweep
//

import Foundation

/// Type-safe enum representing all available scanning phases
public enum ScanningPhaseType: String, CaseIterable, Identifiable, Sendable {
    case libraryAccess = "library_access"
    case imageFetch = "image_fetch"
    case duplicateDetect = "duplicate_detect"
    case temporaryDetect = "temporary_detect"
    case storageAnalysis = "storage_analysis"
    case finalization = "finalization"

    public var id: String { rawValue }

    // MARK: - Display Properties

    /// Human-readable display name
    public var displayName: String {
        switch self {
        case .libraryAccess: return "Accessing photo library..."
        case .imageFetch: return "Gathering images..."
        case .duplicateDetect: return "Detecting duplicates..."
        case .temporaryDetect: return "Identifying temporary files..."
        case .storageAnalysis: return "Analyzing storage..."
        case .finalization: return "Finalizing results..."
        }
    }

    /// SF Symbol icon for UI display
    public var icon: String {
        switch self {
        case .libraryAccess: return "lock.open.fill"
        case .imageFetch: return "photo.on.rectangle.angled"
        case .duplicateDetect: return "doc.on.doc.fill"
        case .temporaryDetect: return "trash.fill"
        case .storageAnalysis: return "internaldrive.fill"
        case .finalization: return "checkmark.circle.fill"
        }
    }

    // MARK: - Timing Properties

    /// Estimated duration in seconds
    public var estimatedDuration: TimeInterval {
        switch self {
        case .libraryAccess: return 1.0
        case .imageFetch: return 2.0
        case .duplicateDetect: return 4.0
        case .temporaryDetect: return 2.0
        case .storageAnalysis: return 1.0
        case .finalization: return 1.0
        }
    }

    /// Weight for overall progress calculation (should sum to 1.0)
    public var progressWeight: Double {
        switch self {
        case .libraryAccess: return 0.1
        case .imageFetch: return 0.2
        case .duplicateDetect: return 0.3
        case .temporaryDetect: return 0.2
        case .storageAnalysis: return 0.1
        case .finalization: return 0.1
        }
    }

    /// Default execution order
    public var defaultOrder: Int {
        switch self {
        case .libraryAccess: return 0
        case .imageFetch: return 1
        case .duplicateDetect: return 2
        case .temporaryDetect: return 3
        case .storageAnalysis: return 4
        case .finalization: return 5
        }
    }

    // MARK: - Static Properties

    /// Default phases for a full scan
    public static var defaultPhases: [ScanningPhaseType] {
        allCases.sorted { $0.defaultOrder < $1.defaultOrder }
    }
}
