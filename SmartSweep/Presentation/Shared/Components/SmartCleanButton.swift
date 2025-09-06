//
//  SmartCleanButton.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

public struct SmartCleanButton: View {
    let action: () -> Void
    let isEnabled: Bool
    let isAnimating: Bool
    
    public init(action: @escaping () -> Void, isEnabled: Bool, isAnimating: Bool) {
        self.action = action
        self.isEnabled = isEnabled
        self.isAnimating = isAnimating
    }
    
    public var body: some View {
        Button(action: action) {
            Text(AppConstants.Strings.smartClean)
                .font(AppConstants.Typography.headlineBold)
                .foregroundColor(AppConstants.Colors.textPrimaryDark)
                .frame(width: 200, height: 200)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppConstants.Colors.accentPinkStart,
                                    AppConstants.Colors.accentPinkEnd
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .clipShape(Circle())
                .contentShape(Circle())
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(AppConstants.Animation.scanPulse, value: isAnimating)
        }
        .disabled(!isEnabled)
        .shadow(color: AppConstants.Colors.accentPinkStart.opacity(0.4), radius: 20, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}
