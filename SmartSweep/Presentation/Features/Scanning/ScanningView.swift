//
//  ScanningView.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 9/14/25.
//

import SwiftUI

public struct ScanningView: View {
    @StateObject private var viewModel: ScanningViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Navigation binding for results
    @Binding var navigateToResults: Bool
    @Binding var scanResult: ScanResult?
    
    public init(viewModel: ScanningViewModel, navigateToResults: Binding<Bool>, scanResult: Binding<ScanResult?>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._navigateToResults = navigateToResults
        self._scanResult = scanResult
    }
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AppConstants.Colors.backgroundDarkTop,
                    AppConstants.Colors.backgroundDarkBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Progress Ring
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(
                            Color.white.opacity(0.1),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppConstants.Colors.accentPinkStart,
                                    AppConstants.Colors.accentPinkEnd
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                    
                    // Progress percentage
                    VStack(spacing: 8) {
                        Text("\(Int(viewModel.progress * 100))%")
                            .font(AppConstants.Typography.titleBold)
                            .foregroundColor(AppConstants.Colors.textPrimaryDark)
                        
                        if viewModel.isScanning {
                            // Scanning animation dots
                            HStack(spacing: 4) {
                                ForEach(0..<3, id: \.self) { index in
                                    Circle()
                                        .fill(AppConstants.Colors.accentPinkStart)
                                        .frame(width: 6, height: 6)
                                        .scaleEffect(viewModel.isScanning ? 1.0 : 0.5)
                                        .animation(
                                            Animation.easeInOut(duration: 0.6)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(index) * 0.2),
                                            value: viewModel.isScanning
                                        )
                                }
                            }
                        }
                    }
                }
                
                // Current task description
                VStack(spacing: 16) {
                    Text("Scanning Your Photos")
                        .font(AppConstants.Typography.headlineBold)
                        .foregroundColor(AppConstants.Colors.textPrimaryDark)
                    
                    Text(viewModel.currentTask)
                            .font(AppConstants.Typography.bodyMedium)
                            .foregroundColor(AppConstants.Colors.textSecondaryDark)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentTask)
                }
                
                Spacer()
                
                // Cancel button (only show if scanning)
                if viewModel.isScanning {
                    Button("Cancel") {
                        viewModel.resetScan()
                        dismiss()
                    }
                    .font(AppConstants.Typography.bodyMedium)
                    .foregroundColor(AppConstants.Colors.textSecondaryDark)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(AppConstants.Colors.textSecondaryDark.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 40)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !viewModel.isScanning {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            viewModel.startScanning()
        }
        .onChange(of: viewModel.isCompleted) { completed in
            if completed, let result = viewModel.scanResult {
                scanResult = result
                navigateToResults = true
            }
        }
        .alert("Scan Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
                dismiss()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

#Preview {
    let imageRepository = ImageRepository()
    let userRepository = UserRepository()
    let cleanImagesUseCase = CleanImagesUseCase(
        imageRepository: imageRepository,
        userRepository: userRepository
    )
    
    let viewModel = ScanningViewModel(
        cleanImagesUseCase: cleanImagesUseCase,
        imageRepository: imageRepository
    )
    
    ScanningView(
        viewModel: viewModel,
        navigateToResults: .constant(false),
        scanResult: .constant(nil)
    )
}

