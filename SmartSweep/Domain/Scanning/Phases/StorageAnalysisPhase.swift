//
//  StorageAnalysisPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class StorageAnalysisPhase: BaseScanningPhase {

    // MARK: - Dependencies

    private let imageRepository: ImageRepositoryProtocol

    // MARK: - Initialization

    public init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
        super.init(phaseType: .storageAnalysis)
    }

    // MARK: - Execution

    public override func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        reportProgress(0.0)

        return imageRepository.getStorageInfo()
            .handleEvents { [weak self] _ in
                self?.reportProgress(0.8)
            }
            .map { storageInfo -> PhaseResult in
                context.storageInfo = storageInfo
                return PhaseResult.success
            }
            .handleEvents { [weak self] _ in
                self?.reportComplete()
            }
            .eraseToAnyPublisher()
    }
}
