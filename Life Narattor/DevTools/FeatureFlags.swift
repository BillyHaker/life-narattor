import Foundation
import Observation

@Observable
final class FeatureFlags {
    static let shared = FeatureFlags()

    private let store = UserDefaults.standard

    var isMockAIEnabled: Bool {
        get { store.bool(forKey: Keys.isMockAIEnabled) }
        set { store.set(newValue, forKey: Keys.isMockAIEnabled) }
    }

    var isVerboseLoggingEnabled: Bool {
        get { store.bool(forKey: Keys.isVerboseLoggingEnabled) }
        set { store.set(newValue, forKey: Keys.isVerboseLoggingEnabled) }
    }

    var isNetworkRecordingEnabled: Bool {
        get { store.bool(forKey: Keys.isNetworkRecordingEnabled) }
        set { store.set(newValue, forKey: Keys.isNetworkRecordingEnabled) }
    }

    var isSeedSampleDataEnabled: Bool {
        get { store.bool(forKey: Keys.isSeedSampleDataEnabled) }
        set { store.set(newValue, forKey: Keys.isSeedSampleDataEnabled) }
    }

    func snapshot() -> [String: Bool] {
        [
            "isMockAIEnabled": isMockAIEnabled,
            "isVerboseLoggingEnabled": isVerboseLoggingEnabled,
            "isNetworkRecordingEnabled": isNetworkRecordingEnabled,
            "isSeedSampleDataEnabled": isSeedSampleDataEnabled
        ]
    }

    private enum Keys {
        static let isMockAIEnabled = "feature.isMockAIEnabled"
        static let isVerboseLoggingEnabled = "feature.isVerboseLoggingEnabled"
        static let isNetworkRecordingEnabled = "feature.isNetworkRecordingEnabled"
        static let isSeedSampleDataEnabled = "feature.isSeedSampleDataEnabled"
    }
}
