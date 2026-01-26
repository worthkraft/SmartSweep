//
//  ScanPermissionValidator.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 15/1/26.
//

import Foundation
import Combine

/// Validates whether a user has permission to perform scans
public class ScanPermissionValidator {
    private let userRepository: UserRepositoryProtocol
    
    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    /// Validates if the current user can perform a deep scan
    /// - Returns: Publisher that emits the user if they can scan, or fails with CleanError.scanLimitReached
    public func validateScanPermission() -> AnyPublisher<User, Error> {
        return userRepository.getCurrentUser()
            .tryMap { user in
                guard user.canPerformDeepScan else {
                    throw CleanError.scanLimitReached
                }
                return user
            }
            .eraseToAnyPublisher()
    }
}
