//
//  LibraryAccessPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class LibraryAccessPhase: BaseScanningPhase {

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol

    // MARK: - Initialization

    public init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
        super.init(phaseType: .libraryAccess)
    }

    // MARK: - Execution

    public override func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        reportProgress(0.0)

        return imageRepository.requestPhotoLibraryAccess()
            .handleEvents { [weak self] _ in
                self?.reportProgress(0.5)
            }
            .flatMap { [weak self] hasAccess -> AnyPublisher<PhaseResult, Error> in
                guard let self = self else {
                    return Fail(error: ScanningError.handlerDeallocated).eraseToAnyPublisher()
                }

                self.reportComplete()

                if hasAccess {
                    return Just(PhaseResult.success)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: ScanningError.phaseFailed(
                        phaseType: .libraryAccess,
                        reason: "Photo library access denied"
                    )).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
