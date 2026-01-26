//
//  DuplicateDetectionPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class DuplicateDetectionPhase: BaseScanningPhase, ClassificationPhaseProtocol {

    // MARK: - ClassificationPhaseProtocol

    public var classificationType: ImageClassificationType { .duplicate }

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol

    // MARK: - Initialization

    public init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
        super.init(phaseType: .duplicateDetect)
    }

    // MARK: - ClassificationPhaseProtocol

    public func classify(images: [SmartImage]) -> AnyPublisher<[ClassificationGroup], Error> {
        imageRepository.detectDuplicates(images: images)
            .map { duplicateGroups -> [ClassificationGroup] in
                duplicateGroups.map { legacyGroup in
                    ClassificationGroup.fromDuplicateGroup(legacyGroup)
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Execution

    public override func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        reportProgress(0.0)

        let totalImages = context.images.count
        guard totalImages > 0 else {
            reportComplete()
            return Just(PhaseResult.success)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return imageRepository.detectDuplicates(images: context.images)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.reportProgress(0.8)
            })
            .map { [weak self] duplicateGroups -> PhaseResult in
                // Legacy: Update context's duplicateGroups
                context.duplicateGroups = duplicateGroups

                // New: Add to classification result
                let classificationGroups = duplicateGroups.map { legacyGroup in
                    ClassificationGroup.fromDuplicateGroup(legacyGroup)
                }
                context.classificationResult.add(groups: classificationGroups, for: self?.classificationType ?? .duplicate)

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
