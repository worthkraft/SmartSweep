//
//  BaseClassificationPhase.swift
//  SmartSweep
//

import Combine
import Foundation

open class BaseClassificationPhase: BaseScanningPhase, ClassificationPhaseProtocol {

    // MARK: - Properties

    public let classificationType: ImageClassificationType

    // MARK: - Initialization

    public init(classificationType: ImageClassificationType, phaseType: ScanningPhaseType) {
        self.classificationType = classificationType
        super.init(phaseType: phaseType)
    }

    // MARK: - ClassificationPhaseProtocol

    /// Subclasses must override this method
    open func classify(images: [SmartImage]) -> AnyPublisher<[ClassificationGroup], Error> {
        fatalError("Subclasses must override classify(images:)")
    }

    // MARK: - ScanningPhaseProtocol Override

    /// Default implementation that delegates to classify and updates context
    open override func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        reportProgress(0.0)

        guard !context.images.isEmpty else {
            reportComplete()
            return Just(PhaseResult.success)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return classify(images: context.images)
            .handleEvents(receiveOutput: { [weak self] groups in
                self?.reportProgress(0.9)

                // Add to classification result
                context.classificationResult.add(groups: groups, for: self?.classificationType ?? .duplicate)
            })
            .map { [weak self] _ -> PhaseResult in
                self?.reportComplete()
                return PhaseResult.success
            }
            .eraseToAnyPublisher()
    }

    open override func canExecute(context: ScanningContext) -> Bool {
        !context.images.isEmpty
    }
}
