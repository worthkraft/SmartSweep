//
//  FinalizationPhase.swift
//  SmartSweep
//

import Combine
import Foundation

public final class FinalizationPhase: BaseScanningPhase {

    // MARK: - Initialization

    public init() {
        super.init(phaseType: .finalization)
    }

    // MARK: - Execution

    public override func execute(context: ScanningContext) -> AnyPublisher<PhaseResult, Error> {
        reportProgress(0.0)

        // Perform any final calculations or cleanup
        reportProgress(0.5)

        // Calculate cleanable space from detected duplicates and temporary files
        let duplicateSpace = context.duplicateGroups.reduce(0) { $0 + $1.savableSpace }
        let temporarySpace = context.temporaryImages.reduce(0) { $0 + $1.fileSize }
        let totalCleanable = duplicateSpace + temporarySpace

        // Update storage info with cleanable space if needed
        if let existingInfo = context.storageInfo {
            context.storageInfo = StorageInfo(
                totalSpace: existingInfo.totalSpace,
                usedSpace: existingInfo.usedSpace,
                availableSpace: existingInfo.availableSpace,
                cleanableSpace: totalCleanable
            )
        }

        reportComplete()

        return Just(PhaseResult.success)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
