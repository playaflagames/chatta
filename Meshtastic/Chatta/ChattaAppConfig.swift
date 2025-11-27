// ChattaAppConfig
// Configuration for Chatta app mode
// Set useChattaUI to true to use the simplified Chatta interface

import Foundation

struct ChattaAppConfig {
    /// Set to true to use Chatta UI instead of Meshtastic UI
    /// This is the main toggle for the reskin
    static let useChattaUI = true

    /// App display name
    static let appName = "Chatta"

    /// Version info
    static let version = "1.0.0"

    /// Default Bluetooth PIN for first-time connections
    static let defaultPIN = "3891"
}

// MARK: - UserDefaults Extension for Chatta Settings
extension UserDefaults {
    private enum ChattaKeys {
        static let useChattaUI = "chatta_useChattaUI"
        static let deviceName = "chatta_deviceName"
        static let notificationsEnabled = "chatta_notificationsEnabled"
        static let soundEnabled = "chatta_soundEnabled"
    }

    var chattaUseChattaUI: Bool {
        get { bool(forKey: ChattaKeys.useChattaUI) }
        set { set(newValue, forKey: ChattaKeys.useChattaUI) }
    }

    var chattaDeviceName: String {
        get { string(forKey: ChattaKeys.deviceName) ?? "" }
        set { set(newValue, forKey: ChattaKeys.deviceName) }
    }

    var chattaNotificationsEnabled: Bool {
        get {
            if object(forKey: ChattaKeys.notificationsEnabled) == nil {
                return true // Default to enabled
            }
            return bool(forKey: ChattaKeys.notificationsEnabled)
        }
        set { set(newValue, forKey: ChattaKeys.notificationsEnabled) }
    }

    var chattaSoundEnabled: Bool {
        get {
            if object(forKey: ChattaKeys.soundEnabled) == nil {
                return true // Default to enabled
            }
            return bool(forKey: ChattaKeys.soundEnabled)
        }
        set { set(newValue, forKey: ChattaKeys.soundEnabled) }
    }
}
