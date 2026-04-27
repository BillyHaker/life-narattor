import Foundation

extension CaptureEntity {
    var resolvedInputMode: CaptureInputMode {
        CaptureInputMode(rawValue: mode ?? "") ?? .log
    }

    var resolvedReviewProcessingState: CaptureProcessingState {
        if let stored = processingState,
           let state = CaptureProcessingState(rawValue: stored) {
            return state
        }

        if cleanText == nil {
            return .pendingClean
        }

        if atomsCount > 0 {
            return .atomsReady
        }

        return .pendingSplit
    }

    var normalizedCleanTextForReview: String? {
        let candidate = (cleanText ?? rawText).trimmingCharacters(in: .whitespacesAndNewlines)
        return candidate.isEmpty ? nil : candidate
    }

    var isFormalRecord: Bool {
        resolvedInputMode == .log
    }

    var isEligibleForReviewTimeline: Bool {
        isFormalRecord
    }

    var shouldAutoAtomizeForFormalRecord: Bool {
        guard isFormalRecord else { return false }
        guard normalizedCleanTextForReview != nil else { return false }
        guard atomsCount == 0 else { return false }

        switch resolvedReviewProcessingState {
        case .cleanReady, .pendingSplit:
            return true
        default:
            return false
        }
    }
}
