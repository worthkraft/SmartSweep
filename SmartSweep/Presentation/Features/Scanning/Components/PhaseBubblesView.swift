//
//  PhaseBubblesView.swift
//  SmartSweep
//

import SwiftUI

/// Horizontal row of phase bubbles showing scanning progress
struct PhaseBubblesView: View {
    let phases: [ScanningPhaseType]
    let states: [ScanningPhaseType: PhaseState]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(phases.enumerated()), id: \.element.id) { index, phaseType in
                    HStack(spacing: 4) {
                        PhaseBubbleView(
                            viewModel: PhaseBubbleViewModel(
                                id: phaseType.id,
                                phaseType: phaseType,
                                state: states[phaseType] ?? .idle
                            )
                        )

                        // Connector line (except for last item)
                        if index < phases.count - 1 {
                            ConnectorLineView(
                                isCompleted: (states[phaseType] ?? .idle).isSuccess,
                                isActive: (states[phaseType] ?? .idle).isActive
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

/// Animated connector line between bubbles
private struct ConnectorLineView: View {
    let isCompleted: Bool
    let isActive: Bool

    var body: some View {
        Rectangle()
            .fill(lineColor)
            .frame(width: 20, height: 2)
            .opacity(isActive ? 0.8 : (isCompleted ? 1.0 : 0.3))
    }

    private var lineColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .blue
        } else {
            return .gray
        }
    }
}

// MARK: - Preview

#Preview {
    PhaseBubblesView(
        phases: ScanningPhaseType.defaultPhases,
        states: [
            .libraryAccess: .finished,
            .imageFetch: .finished,
            .duplicateDetect: .inProgress(progress: 0.45),
            .temporaryDetect: .idle,
            .storageAnalysis: .idle,
            .finalization: .idle
        ]
    )
    .background(Color(.systemBackground))
}
