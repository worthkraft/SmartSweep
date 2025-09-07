//
//  HomeSmartCleanButton.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI
import Foundation

struct HomeSmartCleanButton: View {
    let canPerformDeepScan: Bool
    let userCanPerformDeepScan: Bool
    let isAnimating: Bool
    let onUpgradeTapped: () -> Void
    
    // Reference to the scan view model
    @ObservedObject var scanViewModel: ScanResultsViewModel
    
    var body: some View {
        Group {
            if canPerformDeepScan {
                NavigationLink(value: NavigationDestination.scanResults) {
                    smartCleanButtonContent
                }
                .simultaneousGesture(TapGesture().onEnded {
                    // Perform the scan when tapped
                    scanViewModel.performSmartScan()
                })
            } else {
                Button {
                    if !userCanPerformDeepScan {
                        onUpgradeTapped()
                    }
                } label: {
                    smartCleanButtonContent
                }
            }
        }
    }
    
    private var smartCleanButtonContent: some View {
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
            .disabled(!canPerformDeepScan && userCanPerformDeepScan)
            .shadow(color: AppConstants.Colors.accentPinkStart.opacity(0.4), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}
