//
//  DependencyContainer.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation

public protocol DependencyContainerProtocol {
    func resolve<T>() -> T
}

public class DependencyContainer: DependencyContainerProtocol {
    private var services: [String: Any] = [:]
    
    public static let shared = DependencyContainer()
    
    private init() {
        setupDependencies()
    }
    
    public func register<T>(_ serviceType: T.Type, factory: @escaping () -> T) {
        let key = String(describing: serviceType)
        services[key] = factory
    }
    
    public func resolve<T>() -> T {
        let key = String(describing: T.self)
        guard let factory = services[key] as? () -> T else {
            fatalError("Service of type \(T.self) not registered")
        }
        return factory()
    }
    
    private func setupDependencies() {
        // Register repositories
        register(ImageRepositoryProtocol.self) {
            ImageRepository()
        }
        
        register(UserRepositoryProtocol.self) {
            UserRepository()
        }
        
        // Register services
        register(UserPolicyServiceProtocol.self) {
            UserPolicyService()
        }
        
        register(ImageAnalysisServiceProtocol.self) {
            ImageAnalysisService()
        }
        
        register(ScanPermissionValidator.self) {
            let userRepository: UserRepositoryProtocol = self.resolve()
            return ScanPermissionValidator(userRepository: userRepository)
        }
        
        register(ImageLimitingService.self) {
            ImageLimitingService()
        }
        
        register(ScanExecutor.self) {
            let imageRepository: ImageRepositoryProtocol = self.resolve()
            return ScanExecutor(imageRepository: imageRepository)
        }
        
        // Register use cases
        register(CleanImagesUseCase.self) {
            let imageRepository: ImageRepositoryProtocol = self.resolve()
            let userRepository: UserRepositoryProtocol = self.resolve()
            let permissionValidator: ScanPermissionValidator = self.resolve()
            let imageLimitingService: ImageLimitingService = self.resolve()
            let scanExecutor: ScanExecutor = self.resolve()
            return CleanImagesUseCase(
                imageRepository: imageRepository,
                userRepository: userRepository,
                permissionValidator: permissionValidator,
                imageLimitingService: imageLimitingService,
                scanExecutor: scanExecutor
            )
        }

        // Register Scanning Handler Factory
        register(ScanningHandlerFactory.self) {
            let imageRepository: ImageRepositoryProtocol = self.resolve()
            let userRepository: UserRepositoryProtocol = self.resolve()
            let imageLimitingService: ImageLimitingService = self.resolve()
            return ScanningHandlerFactory(
                imageRepository: imageRepository,
                userRepository: userRepository,
                imageLimitingService: imageLimitingService
            )
        }

        // Register Default Scanning Handler
        register(ScanningHandler.self) {
            let factory: ScanningHandlerFactory = self.resolve()
            return factory.createDefaultHandler()
        }

        // Register ScanningViewModel
        register(ScanningViewModel.self) { @MainActor in
            let scanningHandler: ScanningHandler = self.resolve()
            return ScanningViewModel(scanningHandler: scanningHandler)
        }
    }
}
