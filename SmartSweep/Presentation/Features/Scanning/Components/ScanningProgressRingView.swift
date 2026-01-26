//
//  ScanningProgressRingView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 1/25/26.
//

import SwiftUI

struct ScanningProgressRingView: View {
    let progress: Double
    let isScanning: Bool
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppConstants.Colors.accentPinkStart,
                            AppConstants.Colors.accentPinkEnd
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Progress percentage
            VStack(spacing: 8) {
                Text("\(Int(progress * 100))%")
                    .font(AppConstants.Typography.titleBold)
                    .foregroundColor(AppConstants.Colors.textPrimaryDark)
                
                if isScanning {
                    // Scanning animation dots
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(AppConstants.Colors.accentPinkStart)
                                .frame(width: 6, height: 6)
                                .scaleEffect(isScanning ? 1.0 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: isScanning
                                )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 40) {
            ScanningProgressRingView(progress: 0.0, isScanning: true)
            ScanningProgressRingView(progress: 0.5, isScanning: true)
            ScanningProgressRingView(progress: 1.0, isScanning: false)
        }
    }
}
