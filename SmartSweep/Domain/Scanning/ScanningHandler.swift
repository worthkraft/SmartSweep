//
//  ScanningHandler.swift
//  SmartSweep
//

import Combine
import Foundation

/// Lightweight phase information for UI display
public struct PhaseInfo: Identifiable, Equatable {
    public let phaseType: ScanningPhaseType
    public let progressRange: ClosedRange<Double>

    public var id: String { phaseType.id }
    public var displayName: String { phaseType.displayName }
    public var icon: String { phaseType.icon }
    public var estimatedDuration: TimeInterval { phaseType.estimatedDuration }
}

/// Orchestrates the execution of scanning phases with state notifications
public final class ScanningHandler {

    // MARK: - Properties

    private var phaseRegistry: [ScanningPhaseType: ScanningPhaseProtocol] = [:]
    private var enabledPhases: [ScanningPhaseType] = ScanningPhaseType.defaultPhases
    private var cancellables = Set<AnyCancellable>()
    private var currentContext: ScanningContext?

    private let userRepository: UserRepositoryProtocol

    // MARK: - Publishers

    private let stateSubject = PassthroughSubject<PhaseStateUpdate, Never>()
    public var statePublisher: AnyPublisher<PhaseStateUpdate, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Computed Properties

    /// Returns currently enabled phase types in execution order
    public var phases: [ScanningPhaseType] {
        enabledPhases.sorted { $0.defaultOrder < $1.defaultOrder }
    }

    /// Returns phase info for UI display
    public var phaseInfoList: [PhaseInfo] {
        calculatePhaseInfo()
    }

    // MARK: - Initialization

    public init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    // MARK: - Phase Registration

    /// Register a phase implementation for a specific type
    public func register(phase: ScanningPhaseProtocol) {
        phaseRegistry[phase.phaseType] = phase
    }

    /// Enable a phase type for scanning
    public func enable(phaseType: ScanningPhaseType) {
        guard !enabledPhases.contains(phaseType) else { return }
        enabledPhases.append(phaseType)
        enabledPhases.sort { $0.defaultOrder < $1.defaultOrder }
    }

    /// Disable a phase type from scanning
    public func disable(phaseType: ScanningPhaseType) {
        enabledPhases.removeAll { $0 == phaseType }
    }

    /// Check if a phase type is enabled
    public func isEnabled(phaseType: ScanningPhaseType) -> Bool {
        enabledPhases.contains(phaseType)
    }

    /// Replace a phase implementation
    public func replace(phaseType: ScanningPhaseType, with phase: ScanningPhaseProtocol) {
        guard phase.phaseType == phaseType else { return }
        phaseRegistry[phaseType] = phase
    }

    // MARK: - Execution

    public func startScan() -> AnyPublisher<ScanResult, Error> {
        // Reset all phases to idle
        enabledPhases.forEach { phaseType in
            stateSubject.send(PhaseStateUpdate(phaseType: phaseType, state: .idle))
        }

        return userRepository.getCurrentUser()
            .setFailureType(to: Error.self)
            .flatMap { [weak self] user -> AnyPublisher<ScanResult, Error> in
                guard let self = self else {
                    return Fail(error: ScanningError.handlerDeallocated).eraseToAnyPublisher()
                }

                let context = ScanningContext(user: user)
                self.currentContext = context

                return self.executePhases(context: context)
            }
            .eraseToAnyPublisher()
    }

    public func cancelScan() {
        currentContext?.cancel()

        // Interrupt all active phases
        phaseRegistry.values.forEach { $0.interrupt() }

        // Notify interrupted state for active phases
        enabledPhases.forEach { phaseType in
            stateSubject.send(PhaseStateUpdate(phaseType: phaseType, state: .interrupted))
        }

        cancellables.removeAll()
    }

    // MARK: - Private Methods

    private func executePhases(context: ScanningContext) -> AnyPublisher<ScanResult, Error> {
        let phaseTypes = phases

        var publisher: AnyPublisher<PhaseResult, Error> = Just(PhaseResult.success)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        for phaseType in phaseTypes {
            publisher = publisher
                .flatMap { [weak self] previousResult -> AnyPublisher<PhaseResult, Error> in
                    guard let self = self else {
                        return Fail(error: ScanningError.handlerDeallocated).eraseToAnyPublisher()
                    }

                    guard previousResult.shouldContinue, !context.isCancelled else {
                        return Just(PhaseResult.cancelled)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }

                    guard let phase = self.phaseRegistry[phaseType] else {
                        return Fail(error: ScanningError.phaseNotRegistered(phaseType))
                            .eraseToAnyPublisher()
                    }

                    // Skip phase if it cannot execute
                    guard phase.canExecute(context: context) else {
                        self.stateSubject.send(PhaseStateUpdate(phaseType: phaseType, state: .finished))
                        return Just(PhaseResult.success)
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }

                    return self.executePhase(phase, context: context)
                }
                .eraseToAnyPublisher()
        }

        return publisher
            .map { _ in context.toScanResult() }
            .eraseToAnyPublisher()
    }

    private func executePhase(
        _ phase: ScanningPhaseProtocol,
        context: ScanningContext
    ) -> AnyPublisher<PhaseResult, Error> {
        let phaseType = phase.phaseType

        // Notify started
        stateSubject.send(PhaseStateUpdate(phaseType: phaseType, state: .started))

        // Subscribe to progress updates
        phase.progressPublisher
            .sink { [weak self] progress in
                self?.stateSubject.send(PhaseStateUpdate(
                    phaseType: phaseType,
                    state: .inProgress(progress: progress)
                ))
            }
            .store(in: &cancellables)

        return phase.execute(context: context)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.stateSubject.send(PhaseStateUpdate(phaseType: phaseType, state: .finished))
                },
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.stateSubject.send(PhaseStateUpdate(
                            phaseType: phaseType,
                            state: .failed(error: error.localizedDescription)
                        ))
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    private func calculatePhaseInfo() -> [PhaseInfo] {
        let totalWeight = enabledPhases.reduce(0.0) { $0 + $1.progressWeight }

        var currentProgress: Double = 0.0
        var phaseInfos: [PhaseInfo] = []

        for phaseType in phases {
            let normalizedWeight = phaseType.progressWeight / totalWeight
            let startProgress = currentProgress
            let endProgress = currentProgress + normalizedWeight

            phaseInfos.append(PhaseInfo(
                phaseType: phaseType,
                progressRange: startProgress...endProgress
            ))

            currentProgress = endProgress
        }

        return phaseInfos
    }
}
