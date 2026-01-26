//
//  FloatingPhaseBubbleView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 1/25/26.
//

import SwiftUI

/// A floating bubble representing a single scanning phase with random movement animation
struct FloatingPhaseBubbleView: View {
    let phaseType: ScanningPhaseType
    let state: PhaseState
    let size: CGFloat
    
    @State private var offset: CGSize = .zero
    @State private var isFloating = false
    
    // Random animation parameters for organic movement
    private let floatAmplitude: CGFloat
    private let floatDuration: Double
    private let initialDelay: Double
    
    init(phaseType: ScanningPhaseType, state: PhaseState, size: CGFloat = 70) {
        self.phaseType = phaseType
        self.state = state
        self.size = size
        self.floatAmplitude = CGFloat.random(in: 8...15)
        self.floatDuration = Double.random(in: 2.5...4.0)
        self.initialDelay = Double.random(in: 0...1.5)
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Bubble
            ZStack {
                // Outer glow for active state
                if state.isActive {
                    Circle()
                        .fill(stateColor.opacity(0.3))
                        .frame(width: size + 16, height: size + 16)
                        .blur(radius: 8)
                }
                
                // Progress ring background
                Circle()
                    .stroke(
                        Color.white.opacity(0.15),
                        lineWidth: 3
                    )
                    .frame(width: size, height: size)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: state.progress)
                    .stroke(
                        stateColor,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: state.progress)
                
                // Inner bubble fill
                Circle()
                    .fill(bubbleFillGradient)
                    .frame(width: size - 8, height: size - 8)
                
                // Inner content
                innerContent
            }
            .offset(offset)
            .onAppear {
                startFloatingAnimation()
            }
            .onChange(of: state) { _, _ in
                // Re-trigger animation on state change
                if state.isActive {
                    startFloatingAnimation()
                }
            }
            
            // Label
            Text(shortDisplayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: size + 20)
        }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var innerContent: some View {
        switch state {
        case .finished:
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundColor(.white)
        case .failed:
            Image(systemName: "xmark")
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundColor(.white)
        case .inProgress(let progress):
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold))
                .foregroundColor(.white)
        case .started:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
        default:
            Image(systemName: phaseType.icon)
                .font(.system(size: size * 0.3, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Private Properties
    
    private var stateColor: Color {
        switch state {
        case .idle:
            return Color.gray
        case .started, .inProgress:
            return AppConstants.Colors.accentPinkStart
        case .finished:
            return Color.green
        case .interrupted:
            return Color.orange
        case .failed:
            return Color.red
        }
    }
    
    private var bubbleFillGradient: LinearGradient {
        let baseColor: Color
        switch state {
        case .idle:
            baseColor = Color.gray.opacity(0.3)
        case .started, .inProgress:
            baseColor = AppConstants.Colors.accentPinkStart.opacity(0.4)
        case .finished:
            baseColor = Color.green.opacity(0.5)
        case .interrupted:
            baseColor = Color.orange.opacity(0.5)
        case .failed:
            baseColor = Color.red.opacity(0.5)
        }
        
        return LinearGradient(
            colors: [baseColor, baseColor.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var shortDisplayName: String {
        switch phaseType {
        case .libraryAccess: return "Library\naccess"
        case .imageFetch: return "Fetching\nimages"
        case .duplicateDetect: return "Detecting\nduplicates"
        case .temporaryDetect: return "Identifying\ntemporary..."
        case .storageAnalysis: return "Analyzing\nstorage"
        case .finalization: return "Finalizing\nresults"
        }
    }
    
    // MARK: - Private Methods
    
    private func startFloatingAnimation() {
        // Reset offset
        offset = .zero
        
        DispatchQueue.main.asyncAfter(deadline: .now() + initialDelay) {
            withAnimation(
                .easeInOut(duration: floatDuration)
                .repeatForever(autoreverses: true)
            ) {
                // Random direction for floating
                let randomX = CGFloat.random(in: -floatAmplitude...floatAmplitude)
                let randomY = CGFloat.random(in: -floatAmplitude...floatAmplitude)
                offset = CGSize(width: randomX, height: randomY)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        HStack(spacing: 20) {
            FloatingPhaseBubbleView(
                phaseType: .libraryAccess,
                state: .finished,
                size: 70
            )
            
            FloatingPhaseBubbleView(
                phaseType: .imageFetch,
                state: .inProgress(progress: 0.65),
                size: 70
            )
            
            FloatingPhaseBubbleView(
                phaseType: .duplicateDetect,
                state: .idle,
                size: 70
            )
            
            FloatingPhaseBubbleView(
                phaseType: .temporaryDetect,
                state: .failed(error: "Error"),
                size: 70
            )
        }
    }
}
