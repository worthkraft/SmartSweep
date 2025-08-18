//
//  ProgressRingView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

public struct ProgressRingView: View {
    let usedSpace: Int64
    let totalSpace: Int64
    
    public init(usedSpace: Int64, totalSpace: Int64) {
        self.usedSpace = usedSpace
        self.totalSpace = totalSpace
    }
    
    public var body: some View {
        let pct = Double(usedSpace) / Double(max(totalSpace, 1))
        
        ZStack {
            // Background Ring
            Circle()
                .stroke(
                    AppConstants.Colors.cardSurface,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 240, height: 240)
            
            // Progress Ring with Gradient
            Circle()
                .trim(from: 0, to: pct)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppConstants.Colors.accentPinkStart,
                            AppConstants.Colors.accentPinkEnd
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .animation(AppConstants.Animation.progressBar, value: pct)
            
            // Dark Inner Fill
            Circle()
                .fill(AppConstants.Colors.cardSurface)
                .frame(width: 208, height: 208)
                .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 6)
            
            // Center Content
            VStack(spacing: 8) {
                Text("\(Int(pct * 100))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppConstants.Colors.textPrimaryDark)
                
                Text(AppConstants.Strings.usedLabel)
                    .font(AppConstants.Typography.bodyMedium)
                    .foregroundColor(AppConstants.Colors.textPrimaryDark)
                
                let usedText = ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
                let totalText = ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
                Text("\(usedText) \(AppConstants.Strings.ofLabel) \(totalText)")
                    .font(AppConstants.Typography.captionMedium)
                    .foregroundColor(AppConstants.Colors.textSecondaryDark)
            }
        }
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}
