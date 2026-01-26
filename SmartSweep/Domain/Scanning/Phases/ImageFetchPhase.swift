//
//  ImageFetchPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class ImageFetchPhase: BaseScanningPhase {

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol
    private let imageLimitingService: ImageLimitingService

    // MARK: - Initialization

    public init(
        imageRepository: ImageRepositoryProtocol,
        imageLimitingService: ImageLimitingService
    ) {
        self.imageRepository = imageRepository
        self.imageLimitingService = imageLimitingService
        super.init(phaseType: .imageFetch)
    }

    // MARK: - Execution

    public override func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        reportProgress(0.0)

        return imageRepository.fetchAllImages()
            .handleEvents { [weak self] _ in
                self?.reportProgress(0.7)
            }
            .map { [weak self] images -> [SmartImage] in
                guard let self = self else { return images }

                // Apply user limits
                let limitedImages = self.imageLimitingService.applyLimit(
                    to: images,
                    for: context.user
                )

                self.reportProgress(0.9)
                return limitedImages
            }
            .map { images -> PhaseResult in
                context.images = images
                return PhaseResult.success
            }
            .handleEvents { [weak self] _ in
                self?.reportComplete()
            }
            .eraseToAnyPublisher()
    }
}
