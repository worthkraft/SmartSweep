//
//  HomeView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

public struct HomeView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var scanViewModel: ScanResultsViewModel
    
    init(homeViewModel: HomeViewModel, scanViewModel: ScanResultsViewModel) {
        self._homeViewModel = StateObject(wrappedValue: homeViewModel)
        self._scanViewModel = StateObject(wrappedValue: scanViewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Vertical Gradient Background
                LinearGradient(
                    colors: [
                        AppConstants.Colors.backgroundDarkTop,
                        AppConstants.Colors.backgroundDarkBottom
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    // Main Content - Centered Layout
                    VStack(spacing: 40) {
                        // Large Progress Ring
                        progressRingView
                        
                        // Storage Hint Card
                        storageHintCard
                        
                        // Smart Clean Button
                        smartCleanButton
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
        .onAppear {
            scanViewModel.requestPermissionOnly()
        }
        .alert("Akses Galeri Diperlukan", isPresented: $scanViewModel.showingPermissionAlert) {
            Button("Pengaturan") {
                openSettings()
            }
            Button("Batal", role: .cancel) { }
        } message: {
            Text("SmartSweep memerlukan akses ke galeri foto untuk dapat membersihkan gambar duplikat dan sementara.")
        }
        .alert("Error", isPresented: .constant(scanViewModel.errorMessage != nil)) {
            Button("OK") {
                scanViewModel.errorMessage = nil
            }
        } message: {
            Text(scanViewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $homeViewModel.showingSettings) {
            SettingsView(viewModel: homeViewModel)
        }
        .sheet(isPresented: $homeViewModel.showingScanResults) {
            ScanResultsView(scanResult: $scanViewModel.scanResult)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text(AppConstants.Strings.appName)
                .font(AppConstants.Typography.titleBold)
                .foregroundColor(AppConstants.Colors.textPrimaryDark)
            
            Spacer()
            
            Button(action: {
                homeViewModel.showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppConstants.Colors.textSecondaryDark)
            }
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Progress Ring View
    private var progressRingView: some View {
        let used = homeViewModel.storageInfo?.usedSpace ?? 0
        let total = homeViewModel.storageInfo?.totalSpace ?? max(used, 1)
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
    
    // MARK: - Storage Hint Card
    private var storageHintCard: some View {
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
// MARK: - Smart Clean Button
    private var smartCleanButton: some View {
        Button(action: {
            if homeViewModel.canPerformDeepScan {
                scanViewModel.performSmartScan()
            } else if !homeViewModel.user.canPerformDeepScan {
                homeViewModel.upgradeToPremium()
            }
        }) {
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
                .scaleEffect(scanViewModel.isAnimating ? 1.05 : 1.0)
                .animation(AppConstants.Animation.scanPulse, value: scanViewModel.isAnimating)
        }
        .disabled(!homeViewModel.canPerformDeepScan && homeViewModel.user.canPerformDeepScan)
        .shadow(color: AppConstants.Colors.accentPinkStart.opacity(0.4), radius: 20, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }

// MARK: - Settings View
private struct SettingsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Pengaturan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Selesai") {
                        dismiss()
                    }
                    .foregroundColor(AppConstants.Colors.textPrimaryDark)
                }
            }
        }
    }
}
}
