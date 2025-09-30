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
    @State private var navigateToResults = false
    @State private var scanResult: ScanResult?
    
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
                            isAnimating: false,
                            onUpgradeTapped: {
                                homeViewModel.upgradeToPremium()
                            }
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
                case .scanning:
                    let imageRepository = ImageRepository()
                    let userRepository = UserRepository()
                    let cleanImagesUseCase = CleanImagesUseCase(
                        imageRepository: imageRepository,
                        userRepository: userRepository
                    )
                    let scanningViewModel = ScanningViewModel(
                        cleanImagesUseCase: cleanImagesUseCase,
                        imageRepository: imageRepository
                    )
                    ScanningView(
                        viewModel: scanningViewModel,
                        navigateToResults: $navigateToResults,
                        scanResult: $scanResult
                    )
                case .scanResults:
                    ScanResultsView(scanResult: .constant(scanResult))
                }
            }
            
            .navigationDestination(isPresented: $navigateToResults) {
                ScanResultsView(scanResult: .constant(scanResult))
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
            // View appeared
        }


        .onChange(of: navigateToResults) { _, shouldNavigate in
            if shouldNavigate, let result = scanResult {
                scanViewModel.scanResult = result
                navigateToResults = false
                scanResult = nil
            }
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
