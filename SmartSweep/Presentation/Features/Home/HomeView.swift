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
                    HomeHeaderView(onSettingsTapped: {
                        homeViewModel.showingSettings = true
                    })
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Main Content - Centered Layout
                    VStack(spacing: 40) {
                        // Large Progress Ring
                        HomeProgressRingView(storageInfo: homeViewModel.storageInfo)
                        
                        // Storage Hint Card
                        HomeStorageHintCard()
                        
                        // Smart Clean Button
                        HomeSmartCleanButton(
                            canPerformDeepScan: homeViewModel.canPerformDeepScan,
                            userCanPerformDeepScan: homeViewModel.user.canPerformDeepScan,
                            isAnimating: scanViewModel.isAnimating,
                            onScanTapped: {
                                scanViewModel.performSmartScan()
                            },
                            onUpgradeTapped: {
                                homeViewModel.upgradeToPremium()
                            }
                        )
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
            HomeSettingsView(viewModel: homeViewModel)
        }
        .sheet(isPresented: $homeViewModel.showingScanResults) {
            ScanResultsView(scanResult: $scanViewModel.scanResult)
        }
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }
}
