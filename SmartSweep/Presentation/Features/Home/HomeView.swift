//
//  HomeView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI
import UIKit

public struct HomeView: View {
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var scanViewModel: ScanResultsViewModel
    
    init(homeViewModel: HomeViewModel, scanViewModel: ScanResultsViewModel) {
        self._homeViewModel = StateObject(wrappedValue: homeViewModel)
        self._scanViewModel = StateObject(wrappedValue: scanViewModel)
    }
    
    public var body: some View {
        NavigationStack {
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
                            onUpgradeTapped: {
                                homeViewModel.upgradeToPremium()
                            },
                            scanViewModel: scanViewModel
                        )
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .settings:
                    SettingsView(viewModel: homeViewModel)
                case .scanResults:
                    ScanResultsView(scanResult: $scanViewModel.scanResult)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(AppConstants.Strings.appName)
                        .font(AppConstants.Typography.titleBold)
                        .foregroundColor(AppConstants.Colors.textPrimaryDark)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: NavigationDestination.settings) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppConstants.Colors.textSecondaryDark)
                    }
                }
            }
        }
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
    }
    
    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }
}

#Preview {
    let imageRepository = ImageRepository()
    let userRepository = UserRepository()
    
    var cleanImagesUseCase: CleanImagesUseCase {
        CleanImagesUseCase(imageRepository: imageRepository, userRepository: userRepository)
    }
    
    var homeViewModel: HomeViewModel {
        HomeViewModel(
            userRepository: userRepository,
            imageRepository: imageRepository
        )
    }
    
    var scanViewModel: ScanResultsViewModel {
        ScanResultsViewModel(
            cleanImagesUseCase: cleanImagesUseCase,
            imageRepository: imageRepository
        )
    }
    
    HomeView(
        homeViewModel: homeViewModel,
        scanViewModel: scanViewModel
    )
}
