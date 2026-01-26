//
//  ClassificationPhaseProtocol.swift
//  SmartSweep
//

import Combine
import Foundation

public protocol ClassificationPhaseProtocol: ScanningPhaseProtocol {

    /// The classification type this phase produces
    var classificationType: ImageClassificationType { get }

    /// Classify the given images and return classification groups
    /// - Parameter images: Images to classify
    /// - Returns: Publisher emitting classification groups
    func classify(images: [SmartImage]) -> AnyPublisher<[ClassificationGroup], Error>
}

// MARK: - Default Implementation

public extension ClassificationPhaseProtocol {

    /// Default implementation that maps execute to classify
    /// Phases can override execute directly if they need more control
    func executeClassification(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        classify(images: context.images)
            .map { [weak self] groups -> PhaseResult in
                guard let self = self else { return .cancelled }

                // Add groups to context's classification result
                context.classificationResult.add(groups: groups, for: self.classificationType)

                return PhaseResult.success
            }
            .eraseToAnyPublisher()
    }
}
