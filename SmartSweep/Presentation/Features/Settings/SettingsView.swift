//
//  HomeSettingsView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            // Dark gradient background for settings
            LinearGradient(
                colors: [
                    AppConstants.Colors.backgroundDarkTop,
                    AppConstants.Colors.backgroundDarkBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Premium Status
                VStack(spacing: 16) {
                    let statusColor = viewModel.user.isPremium ?
                        AppConstants.Colors.success : AppConstants.Colors.warning
                    
                    Text(viewModel.user.isPremium ? "Premium Active" : "Free Tier")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                    
                    if !viewModel.user.isPremium {
                        Button("Upgrade ke Premium - \(AppConstants.Pricing.premiumPrice)") {
                            viewModel.upgradeToPremium()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    AppConstants.Colors.accentPinkStart,
                                    AppConstants.Colors.accentPinkEnd
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                }
                .padding()
                .background(AppConstants.Colors.cardSurface)
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
