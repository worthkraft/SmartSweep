//
//  HomeProgressRingView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

struct HomeProgressRingView: View {
    let storageInfo: StorageInfo?
    
    var body: some View {
        let used = storageInfo?.usedSpace ?? 0
        let total = storageInfo?.totalSpace ?? max(used, 1)
        let pct = Double(used) / Double(total)
        
        return ZStack {
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
                
                let usedText = ByteCountFormatter.string(fromByteCount: Int64(used), countStyle: .file)
                let totalText = ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file)
                Text("\(usedText) \(AppConstants.Strings.ofLabel) \(totalText)")
                    .font(AppConstants.Typography.captionMedium)
                    .foregroundColor(AppConstants.Colors.textSecondaryDark)
            }
        }
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}
