//
//  DuplicateDetectionPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class DuplicateDetectionPhase: BaseScanningPhase {

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol

    // MARK: - Initialization

    public init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
        super.init(phaseType: .duplicateDetect)
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
            .handleEvents { [weak self] _ in
                self?.reportProgress(0.8)
            }
            .map { duplicateGroups -> PhaseResult in
                context.duplicateGroups = duplicateGroups
                return PhaseResult.success
            }
            .handleEvents { [weak self] _ in
                self?.reportComplete()
            }
            .eraseToAnyPublisher()
    }

    public override func canExecute(context: ScanningContext) -> Bool {
        !context.images.isEmpty
    }
}
