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
        
        // Register use cases
        register(CleanImagesUseCase.self) {
            let imageRepository: ImageRepositoryProtocol = self.resolve()
            let userRepository: UserRepositoryProtocol = self.resolve()
            return CleanImagesUseCase(imageRepository: imageRepository, userRepository: userRepository)
        }
    }
}
