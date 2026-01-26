//
//  TemporaryDetectionPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class TemporaryDetectionPhase: BaseScanningPhase, ClassificationPhaseProtocol {

    // MARK: - ClassificationPhaseProtocol

    public var classificationType: ImageClassificationType { .temporary }

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol

    // MARK: - Initialization

    public init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
        super.init(phaseType: .temporaryDetect)
    }

    // MARK: - ClassificationPhaseProtocol

    public func classify(images: [SmartImage]) -> AnyPublisher<[ClassificationGroup], Error> {
        imageRepository.detectTemporaryImages(images: images)
            .map { temporaryImages -> [ClassificationGroup] in
                // Each temporary image is its own group
                temporaryImages.map { image in
                    ClassificationGroup.individual(type: .temporary, image: image)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Execution

    public override func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        reportProgress(0.0)

        guard !context.images.isEmpty else {
            reportComplete()
            return Just(PhaseResult.success)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return imageRepository.detectTemporaryImages(images: context.images)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.reportProgress(0.8)
            })
            .map { [weak self] temporaryImages -> PhaseResult in
                // Legacy: Update context's temporaryImages
                context.temporaryImages = temporaryImages

                // New: Add to classification result
                let classificationGroups = temporaryImages.map { image in
                    ClassificationGroup.individual(type: .temporary, image: image)
                }
                context.classificationResult.add(groups: classificationGroups, for: self?.classificationType ?? .temporary)

                return PhaseResult.success
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.reportComplete()
            })
            .eraseToAnyPublisher()
    }

    public override func canExecute(context: ScanningContext) -> Bool {
        !context.images.isEmpty
    }
}
