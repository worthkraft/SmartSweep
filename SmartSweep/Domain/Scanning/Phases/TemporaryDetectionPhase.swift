//
//  TemporaryDetectionPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class TemporaryDetectionPhase: BaseScanningPhase {

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol

    // MARK: - Initialization

    public init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
        super.init(phaseType: .temporaryDetect)
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
            .handleEvents { [weak self] _ in
                self?.reportProgress(0.8)
            }
            .map { temporaryImages -> PhaseResult in
                context.temporaryImages = temporaryImages
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
