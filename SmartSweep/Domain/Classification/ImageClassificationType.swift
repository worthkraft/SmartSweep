//
//  ImageClassificationType.swift
//  SmartSweep
//

import Foundation
import SwiftUI

public enum ImageClassificationType: String, CaseIterable, Identifiable, Codable, Sendable {
    case duplicate = "duplicate"
    case temporary = "temporary"
    case screenshot = "screenshot"
    case blurry = "blurry"
    case similar = "similar"
    case lowQuality = "low_quality"
    case oldPhotos = "old_photos"

    // MARK: - Identifiable

    public var id: String { rawValue }

    // MARK: - Display Properties

    /// Localized display name for the classification
    public var displayName: String {
        switch self {
        case .duplicate: return "Duplikat"
        case .temporary: return "Sementara"
        case .screenshot: return "Screenshot"
        case .blurry: return "Buram"
        case .similar: return "Mirip"
        case .lowQuality: return "Kualitas Rendah"
        case .oldPhotos: return "Foto Lama"
        }
    }

    /// Localized description explaining what this classification means
    public var description: String {
        switch self {
        case .duplicate: return "Foto identik yang menghabiskan ruang"
        case .temporary: return "Foto sementara yang bisa dihapus"
        case .screenshot: return "Tangkapan layar"
        case .blurry: return "Foto yang tidak fokus atau buram"
        case .similar: return "Foto yang sangat mirip"
        case .lowQuality: return "Foto dengan resolusi rendah"
        case .oldPhotos: return "Foto yang sudah lebih dari setahun"
        }
    }

    /// SF Symbol icon for UI display
    public var icon: String {
        switch self {
        case .duplicate: return "doc.on.doc.fill"
        case .temporary: return "clock.fill"
        case .screenshot: return "rectangle.on.rectangle"
        case .blurry: return "camera.filters"
        case .similar: return "square.stack.3d.up.fill"
        case .lowQuality: return "exclamationmark.triangle.fill"
        case .oldPhotos: return "calendar.badge.clock"
        }
    }

    /// Primary color for UI theming
    public var color: Color {
        switch self {
        case .duplicate: return .red
        case .temporary: return .orange
        case .screenshot: return .purple
        case .blurry: return .yellow
        case .similar: return .blue
        case .lowQuality: return .gray
        case .oldPhotos: return .brown
        }
    }

    /// Whether this classification groups images together (like duplicates)
    /// or treats each image individually (like screenshots)
    public var isGrouped: Bool {
        switch self {
        case .duplicate, .similar: return true
        case .temporary, .screenshot, .blurry, .lowQuality, .oldPhotos: return false
        }
    }

    /// Default priority for display order (lower = higher priority)
    public var displayOrder: Int {
        switch self {
        case .duplicate: return 0
        case .similar: return 1
        case .temporary: return 2
        case .screenshot: return 3
        case .blurry: return 4
        case .lowQuality: return 5
        case .oldPhotos: return 6
        }
    }

    /// Whether this classification is available for free users
    public var requiresPremium: Bool {
        switch self {
        case .duplicate, .temporary, .screenshot: return false
        case .blurry, .similar, .lowQuality, .oldPhotos: return true
        }
    }

    /// Maps to corresponding ScanningPhaseType (if applicable)
    public var scanningPhaseType: ScanningPhaseType? {
        switch self {
        case .duplicate: return .duplicateDetect
        case .temporary: return .temporaryDetect
        default: return nil
        }
    }

    // MARK: - Utility

    /// Returns all classifications that should be displayed for current user
    public static func availableTypes(for user: User) -> [ImageClassificationType] {
        allCases.filter { !$0.requiresPremium || user.isPremium }
            .sorted { $0.displayOrder < $1.displayOrder }
    }

    /// Default classifications for scanning
    public static var defaultTypes: [ImageClassificationType] {
        [.duplicate, .temporary]
    }

    /// Currently implemented classification types
    public static var implementedTypes: [ImageClassificationType] {
        [.duplicate, .temporary]
    }
}
