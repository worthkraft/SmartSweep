//
//  ScanningHandlerFactory.swift
//  SmartSweep
//

import Foundation

/// Factory for creating pre-configured ScanningHandler instances
public final class ScanningHandlerFactory {

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let imageLimitingService: ImageLimitingService

    // MARK: - Initialization

    public init(
        imageRepository: ImageRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        imageLimitingService: ImageLimitingService
    ) {
        self.imageRepository = imageRepository
        self.userRepository = userRepository
        self.imageLimitingService = imageLimitingService
    }

    // MARK: - Factory Methods

    /// Creates a handler with all default phases registered
    public func createDefaultHandler() -> ScanningHandler {
        let handler = ScanningHandler(userRepository: userRepository)

        registerDefaultPhases(to: handler)

        return handler
    }

    /// Creates a handler with only duplicate detection phases
    public func createDuplicateOnlyHandler() -> ScanningHandler {
        let handler = ScanningHandler(userRepository: userRepository)

        // Register all phases
        registerDefaultPhases(to: handler)

        // Disable non-essential phases
        handler.disable(phaseType: .temporaryDetect)
        handler.disable(phaseType: .storageAnalysis)

        return handler
    }

    /// Creates a handler with custom phase types enabled
    public func createCustomHandler(enabledPhases: [ScanningPhaseType]) -> ScanningHandler {
        let handler = ScanningHandler(userRepository: userRepository)

        // Register all phases first
        registerDefaultPhases(to: handler)

        // Disable all phases
        ScanningPhaseType.allCases.forEach { handler.disable(phaseType: $0) }

        // Enable only requested phases
        enabledPhases.forEach { handler.enable(phaseType: $0) }

        return handler
    }

    // MARK: - Private

    private func registerDefaultPhases(to handler: ScanningHandler) {
        handler.register(phase: LibraryAccessPhase(imageRepository: imageRepository))
        handler.register(phase: ImageFetchPhase(
            imageRepository: imageRepository,
            imageLimitingService: imageLimitingService
        ))
        handler.register(phase: DuplicateDetectionPhase(imageRepository: imageRepository))
        handler.register(phase: TemporaryDetectionPhase(imageRepository: imageRepository))
        handler.register(phase: StorageAnalysisPhase(imageRepository: imageRepository))
        handler.register(phase: FinalizationPhase())
    }
}
