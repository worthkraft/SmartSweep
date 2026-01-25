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

    // MARK: - Body

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

            VStack(spacing: 24) {
                Spacer()

                // Floating Phase Bubbles Animation
                FloatingPhaseBubblesView(
                    phases: viewModel.enabledPhases,
                    states: viewModel.phaseStates
                )

                // Progress Ring
                ScanningProgressRingView(
                    progress: viewModel.overallProgress,
                    isScanning: viewModel.isScanning
                )

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
                        viewModel.cancelScan()
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
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                handleScanCompletion()
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

    // MARK: - Private Methods

    private func handleScanCompletion() {
        guard let result = viewModel.scanResult else { return }
        
        scanResult = result
        dismiss()
        
        // Navigate to results after dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigateToResults = true
        }
    }
}

#Preview {
    let imageRepository = ImageRepository()
    let userRepository = UserRepository()
    let imageLimitingService = ImageLimitingService()

    let factory = ScanningHandlerFactory(
        imageRepository: imageRepository,
        userRepository: userRepository,
        imageLimitingService: imageLimitingService
    )

    let viewModel = ScanningViewModel(scanningHandler: factory.createDefaultHandler())

    ScanningView(
        viewModel: viewModel,
        navigateToResults: .constant(false),
        scanResult: .constant(nil)
    )
}

