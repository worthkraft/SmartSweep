//
//  PhaseBubbleView.swift
//  SmartSweep
//

import SwiftUI

/// Animated bubble representing a single scanning phase
struct PhaseBubbleView: View {
    let viewModel: PhaseBubbleViewModel

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background circle
                Circle()
                    .fill(viewModel.backgroundColor)
                    .frame(width: 56, height: 56)

                // Pulsing ring for active state
                if viewModel.isAnimating {
                    Circle()
                        .stroke(viewModel.backgroundColor, lineWidth: 2)
                        .frame(width: 56, height: 56)
                        .scaleEffect(isAnimating ? 1.4 : 1.0)
                        .opacity(isAnimating ? 0 : 0.6)
                        .animation(
                            .easeOut(duration: 1.0).repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }

                // Icon or progress text
                if let progressText = viewModel.progressText {
                    Text(progressText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(viewModel.foregroundColor)
                } else {
                    Image(systemName: viewModel.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(viewModel.foregroundColor)
                }
            }
            .opacity(viewModel.opacity)

            // Phase name
            Text(viewModel.phaseType.displayName.replacingOccurrences(of: "...", with: ""))
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 70)
        }
        .onAppear {
            if viewModel.isAnimating {
                isAnimating = true
            }
        }
        .onChange(of: viewModel.isAnimating) { _, newValue in
            isAnimating = newValue
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 16) {
        PhaseBubbleView(viewModel: PhaseBubbleViewModel(
            id: "1",
            phaseType: .libraryAccess,
            state: .finished
        ))

        PhaseBubbleView(viewModel: PhaseBubbleViewModel(
            id: "2",
            phaseType: .imageFetch,
            state: .inProgress(progress: 0.65)
        ))

        PhaseBubbleView(viewModel: PhaseBubbleViewModel(
            id: "3",
            phaseType: .duplicateDetect,
            state: .idle
        ))
    }
    .padding()
}
