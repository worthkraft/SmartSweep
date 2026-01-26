//
//  PhaseBubbleViewModel.swift
//  SmartSweep
//

import Foundation
import SwiftUI

/// ViewModel for individual phase bubble
struct PhaseBubbleViewModel: Identifiable {
    let id: String
    let phaseType: ScanningPhaseType
    let state: PhaseState

    var icon: String { phaseType.icon }
    var displayName: String { phaseType.displayName }

    var backgroundColor: Color {
        switch state {
        case .idle:
            return .gray.opacity(0.3)
        case .started, .inProgress:
            return .blue
        case .finished:
            return .green
        case .interrupted:
            return .orange
        case .failed:
            return .red
        }
    }

    var foregroundColor: Color {
        switch state {
        case .idle:
            return .gray
        default:
            return .white
        }
    }

    var isAnimating: Bool {
        state.isActive
    }

    var progressText: String? {
        switch state {
        case .inProgress(let progress):
            return "\(Int(progress * 100))%"
        case .finished:
            return "✓"
        case .failed:
            return "✗"
        default:
            return nil
        }
    }

    var opacity: Double {
        switch state {
        case .idle:
            return 0.6
        default:
            return 1.0
        }
    }
}
