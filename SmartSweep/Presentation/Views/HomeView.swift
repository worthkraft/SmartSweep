//
//  HomeView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppConstants.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Main Content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Storage Dashboard
                            storageDashboard
                            
                            // Smart Scan Button
                            smartScanButton
                            
                            // Progress Indicator
                            if viewModel.scanStatus == .scanning {
                                scanProgressView
                            }
                            
                            // Success Message
                            if let successMessage = viewModel.scanSuccessMessage {
                                successMessageView(successMessage)
                            }
                            
                            // Suggested Actions
                            if viewModel.hasSuggestions {
                                suggestedActions
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.requestPermissionOnly()
        }
        .alert("Akses Galeri Diperlukan", isPresented: $viewModel.showingPermissionAlert) {
            Button("Pengaturan") {
                openSettings()
            }
            Button("Batal", role: .cancel) { }
        } message: {
            Text("SmartSweep memerlukan akses ke galeri foto untuk dapat membersihkan gambar duplikat dan sementara.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingScanResults) {
            ScanResultsView(scanResult: $viewModel.scanResult)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text(AppConstants.Strings.appName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppConstants.Colors.primary)
            
            Spacer()
            
            Button(action: {
                viewModel.showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(AppConstants.Colors.textPrimary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Storage Dashboard
    private var storageDashboard: some View {
        VStack(spacing: 16) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(AppConstants.Colors.cardBackground, lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: viewModel.storageInfo?.usagePercentage ?? 0)
                    .stroke(
                        LinearGradient(
                            colors: [AppConstants.Colors.primary, AppConstants.Colors.primary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(AppConstants.Animation.progressBar, value: viewModel.storageInfo?.usagePercentage)
                
                VStack(spacing: 4) {
                    Text(viewModel.storageInfo?.formattedUsedSpace ?? "0 GB")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("/ \(viewModel.storageInfo?.formattedTotalSpace ?? "0 GB")")
                        .font(.caption)
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
            }
            
            // Cleanable Space Info
            if let cleanableSpace = viewModel.storageInfo?.cleanableSpace, cleanableSpace > 0 {
                HStack {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(AppConstants.Colors.warning)
                    let cleanableText = "\(viewModel.storageInfo?.formattedCleanableSpace ?? "0 MB")"
                    Text("\(cleanableText) \(AppConstants.Strings.cleanable)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppConstants.Colors.warning.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding()
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Smart Scan Button
    private var smartScanButton: some View {
        VStack(spacing: 8) {
            Button(action: {
                if viewModel.canPerformScan {
                    viewModel.performSmartScan()
                } else if !viewModel.user.canPerformDeepScan {
                    viewModel.upgradeToPremium()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .scaleEffect(viewModel.isAnimating ? 1.1 : 1.0)
                        .animation(AppConstants.Animation.scanPulse, value: viewModel.isAnimating)
                    
                    Text(viewModel.scanButtonText)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(viewModel.canPerformScan ?
                              AppConstants.Colors.primary : AppConstants.Colors.textSecondary)
                        .scaleEffect(viewModel.isAnimating ? 1.05 : 1.0)
                        .animation(AppConstants.Animation.buttonPress, value: viewModel.isAnimating)
                )
            }
            .disabled(!viewModel.canPerformScan && viewModel.user.canPerformDeepScan)
            .scaleEffect(viewModel.isAnimating ? 0.95 : 1.0)
            .animation(AppConstants.Animation.buttonPress, value: viewModel.isAnimating)
            
            // Show limitation message for free users
            if !viewModel.user.canPerformDeepScan {
                Text("Batas scan mingguan tercapai. Upgrade ke Premium untuk scan unlimited.")
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.warning)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Scan Progress View
    private var scanProgressView: some View {
        VStack(spacing: 12) {
            ProgressView(value: viewModel.scanProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: AppConstants.Colors.primary))
                .scaleEffect(y: 2)
            
            Text(viewModel.scanProgressText)
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - Success Message View
    private func successMessageView(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundColor(AppConstants.Colors.success)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppConstants.Colors.success.opacity(0.1))
                    .stroke(AppConstants.Colors.success.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - Suggested Actions
    private var suggestedActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saran Pembersihan")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            VStack(spacing: 12) {
                // Duplicates
                if let result = viewModel.scanResult, !result.duplicateGroups.isEmpty {
                    let savedSpace = result.duplicateGroups.reduce(0) { $0 + $1.savableSpace }
                    let formattedSpace = ByteCountFormatter.string(fromByteCount: savedSpace, countStyle: .file)
                    
                    SuggestionCard(
                        icon: "doc.on.doc.fill",
                        title: "\(AppConstants.Strings.duplicates) (\(result.duplicateCount))",
                        subtitle: "Hemat \(formattedSpace)",
                        actionTitle: AppConstants.Strings.cleanNow,
                        action: viewModel.cleanDuplicates
                    )
                }
                
                // Temporary Images
                if let result = viewModel.scanResult, !result.temporaryImages.isEmpty {
                    SuggestionCard(
                        icon: "clock.fill",
                        title: "\(AppConstants.Strings.temporaryImages) (\(result.temporaryCount))",
                        subtitle: "Gambar pembayaran & lokasi",
                        actionTitle: AppConstants.Strings.review,
                        action: viewModel.cleanTemporaryImages
                    )
                }
                
                // Premium Feature (Screenshots)
                if !viewModel.user.isPremium {
                    SuggestionCard(
                        icon: "camera.viewfinder",
                        title: "Filter Screenshot",
                        subtitle: "Fitur Premium",
                        actionTitle: "🔒 Upgrade",
                        isPremium: true,
                        action: viewModel.upgradeToPremium
                    )
                }
            }
        }
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }
}

// MARK: - Suggestion Card
struct SuggestionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let isPremium: Bool
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String,
        isPremium: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.isPremium = isPremium
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isPremium ? AppConstants.Colors.warning : AppConstants.Colors.primary)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            
            Spacer()
            
            // Action Button
            Button(action: action) {
                Text(actionTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isPremium ? AppConstants.Colors.warning : AppConstants.Colors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isPremium ? AppConstants.Colors.warning : AppConstants.Colors.primary, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Premium Status
                VStack(spacing: 16) {
                    let statusColor = viewModel.user.isPremium ?
                        AppConstants.Colors.success : AppConstants.Colors.textPrimary
                    
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
                        .background(AppConstants.Colors.primary)
                        .cornerRadius(25)
                    }
                }
                .padding()
                .background(AppConstants.Colors.cardBackground)
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Pengaturan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Selesai") {
                        dismiss()
                    }
                }
            }
        }
    }
}
