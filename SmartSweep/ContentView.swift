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
            cleanImagesUseCase: cleanImagesUseCase,
            userRepository: userRepository,
            imageRepository: imageRepository
        )
    }
    
    var body: some View {
        HomeView(viewModel: homeViewModel)
    }
}

#Preview {
    ContentView()
}
