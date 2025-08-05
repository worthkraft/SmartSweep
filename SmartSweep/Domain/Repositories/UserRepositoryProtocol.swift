//
//  UserRepository.swift
//  SmartSweep
//
//  Created by Rizky Hasibuan on 7/9/25.
//

import Foundation
import Combine

public protocol UserRepositoryProtocol {
    func getCurrentUser() -> AnyPublisher<User, Never>
    func updateUser(_ user: User) -> AnyPublisher<Void, Never>
    func purchasePremium() -> AnyPublisher<Bool, Error>
    func restorePurchases() -> AnyPublisher<Bool, Error>
}
