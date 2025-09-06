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
        CleanImagesUseCase(imageRepository: imageRepository, userRepository: userRepository)
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
