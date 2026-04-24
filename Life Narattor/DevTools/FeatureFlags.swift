import Foundation
import Combine

final class FeatureFlags: ObservableObject {
    static let shared = FeatureFlags()

    private let store = UserDefaults.standard

    var isVerboseLoggingEnabled: Bool {
        get { store.bool(forKey: Keys.isVerboseLoggingEnabled) }
        set { set(newValue, for: Keys.isVerboseLoggingEnabled) }
    }

    var isNetworkRecordingEnabled: Bool {
        get { store.bool(forKey: Keys.isNetworkRecordingEnabled) }
        set { set(newValue, for: Keys.isNetworkRecordingEnabled) }
    }

    var isSeedSampleDataEnabled: Bool {
        get { store.bool(forKey: Keys.isSeedSampleDataEnabled) }
        set { set(newValue, for: Keys.isSeedSampleDataEnabled) }
    }

    var isTranscriptionFailureSimulated: Bool {
        get {
#if DEBUG
            return store.bool(forKey: Keys.isTranscriptionFailureSimulated)
#else
            return false
#endif
        }
        set { set(newValue, for: Keys.isTranscriptionFailureSimulated) }
    }

    var isTranscriptionOfflineSimulated: Bool {
        get {
#if DEBUG
            return store.bool(forKey: Keys.isTranscriptionOfflineSimulated)
#else
            return false
#endif
        }
        set { set(newValue, for: Keys.isTranscriptionOfflineSimulated) }
    }

    var isAITranscriptionPreferred: Bool {
        get { store.bool(forKey: Keys.isAITranscriptionPreferred) }
        set { set(newValue, for: Keys.isAITranscriptionPreferred) }
    }

    func snapshot() -> [String: Bool] {
        [
            "isVerboseLoggingEnabled": isVerboseLoggingEnabled,
            "isNetworkRecordingEnabled": isNetworkRecordingEnabled,
            "isSeedSampleDataEnabled": isSeedSampleDataEnabled,
            "isTranscriptionFailureSimulated": isTranscriptionFailureSimulated,
            "isTranscriptionOfflineSimulated": isTranscriptionOfflineSimulated,
            "isAITranscriptionPreferred": isAITranscriptionPreferred
        ]
    }

    private enum Keys {
        static let isVerboseLoggingEnabled = "feature.isVerboseLoggingEnabled"
        static let isNetworkRecordingEnabled = "feature.isNetworkRecordingEnabled"
        static let isSeedSampleDataEnabled = "feature.isSeedSampleDataEnabled"
        static let isTranscriptionFailureSimulated = "feature.isTranscriptionFailureSimulated"
        static let isTranscriptionOfflineSimulated = "feature.isTranscriptionOfflineSimulated"
        static let isAITranscriptionPreferred = "feature.isAITranscriptionPreferred"
    }

    private func set(_ value: Bool, for key: String) {
        objectWillChange.send()
        store.set(value, forKey: key)
    }
}
