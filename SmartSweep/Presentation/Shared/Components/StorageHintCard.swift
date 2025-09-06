//
//  StorageHintCard.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

public struct StorageHintCard: View {
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            Text(AppConstants.Strings.storageHint)
                .font(AppConstants.Typography.headlineBold)
                .foregroundColor(AppConstants.Colors.textPrimaryDark)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            AppConstants.Colors.cardSurface,
                            AppConstants.Colors.cardSurface.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}
