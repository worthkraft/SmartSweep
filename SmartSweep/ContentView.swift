//
//  ContentView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import SwiftUI

struct ContentView: View {
    private let imageRepository = ImageRepository()
    private let userRepository = UserRepository()
    
    private var cleanImagesUseCase: CleanImagesUseCase {
        let permissionValidator = ScanPermissionValidator(userRepository: userRepository)
        let imageLimitingService = ImageLimitingService()
        let scanExecutor = ScanExecutor(imageRepository: imageRepository)
        return CleanImagesUseCase(
            imageRepository: imageRepository,
            userRepository: userRepository,
            permissionValidator: permissionValidator,
            imageLimitingService: imageLimitingService,
            scanExecutor: scanExecutor
        )
    }
    
    private var homeViewModel: HomeViewModel {
        HomeViewModel(
            userRepository: userRepository,
            imageRepository: imageRepository
        )
    }
    
    private var scanViewModel: ScanResultsViewModel {
        ScanResultsViewModel(
            cleanImagesUseCase: cleanImagesUseCase,
            imageRepository: imageRepository
        )
    }
    
    var body: some View {
        HomeView(
            homeViewModel: homeViewModel,
            scanViewModel: scanViewModel
        )
    }
}

#Preview {
    ContentView()
}
