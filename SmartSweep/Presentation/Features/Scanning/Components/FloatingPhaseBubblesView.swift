//
//  FloatingPhaseBubblesView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 1/25/26.
//

import SwiftUI

/// A container view that displays scanning phases as floating bubbles in an organic layout
struct FloatingPhaseBubblesView: View {
    let phases: [ScanningPhaseType]
    let states: [ScanningPhaseType: PhaseState]
    
    // Layout configuration for bubble positions (relative to container)
    private let bubblePositions: [BubblePosition] = [
        BubblePosition(xRatio: 0.15, yRatio: 0.3, size: 65),   // Library access - top left
        BubblePosition(xRatio: 0.42, yRatio: 0.15, size: 72),  // Image fetch - top center
        BubblePosition(xRatio: 0.75, yRatio: 0.28, size: 68),  // Duplicate detect - top right
        BubblePosition(xRatio: 0.22, yRatio: 0.7, size: 70),   // Temporary detect - bottom left
        BubblePosition(xRatio: 0.55, yRatio: 0.75, size: 66),  // Storage analysis - bottom center
        BubblePosition(xRatio: 0.85, yRatio: 0.65, size: 72)   // Finalization - bottom right
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw connecting lines between bubbles
                connectingLines(in: geometry.size)
                
                // Draw floating bubbles
                ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                    if index < bubblePositions.count {
                        let position = bubblePositions[index]
                        FloatingPhaseBubbleView(
                            phaseType: phase,
                            state: states[phase] ?? .idle,
                            size: position.size
                        )
                        .position(
                            x: geometry.size.width * position.xRatio,
                            y: geometry.size.height * position.yRatio
                        )
                    }
                }
            }
        }
        .frame(height: 280)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private func connectingLines(in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let positions = bubblePositions.prefix(phases.count).map { position in
                CGPoint(
                    x: canvasSize.width * position.xRatio,
                    y: canvasSize.height * position.yRatio
                )
            }
            
            // Draw lines connecting adjacent phases
            for i in 0..<(positions.count - 1) {
                let start = positions[i]
                let end = positions[i + 1]
                
                let phase = phases[i]
                let state = states[phase] ?? .idle
                
                var path = Path()
                path.move(to: start)
                path.addLine(to: end)
                
                // Color based on state
                let lineColor: Color
                if state.isSuccess {
                    lineColor = .green.opacity(0.4)
                } else if state.isActive {
                    lineColor = AppConstants.Colors.accentPinkStart.opacity(0.4)
                } else {
                    lineColor = .gray.opacity(0.2)
                }
                
                context.stroke(
                    path,
                    with: .color(lineColor),
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 5])
                )
            }
        }
    }
}

// MARK: - Supporting Types

private struct BubblePosition {
    let xRatio: CGFloat
    let yRatio: CGFloat
    let size: CGFloat
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [
                AppConstants.Colors.backgroundDarkTop,
                AppConstants.Colors.backgroundDarkBottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        VStack {
            FloatingPhaseBubblesView(
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
            .padding()
        }
    }
}
