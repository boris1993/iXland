import os
import SwiftUI
import Foundation

class LoggerHelper {
    static func getLoggerForView(name: String) -> Logger {
        return Logger(
            subsystem: name,
            category: "view"
        )
    }

    static func getLoggerForPersistence(name: String) -> Logger {
        return Logger(
            subsystem: name,
            category: "persistence"
        )
    }
}

class ThemeHelper {
    static func setAppTheme(themePickerSelectedValue: Themes) {
        switch themePickerSelectedValue {
        case Themes.light:
            changeDarkMode(isDarkModeOn: false)
        case Themes.dark:
            changeDarkMode(isDarkModeOn: true)
        }
    }

    private static func changeDarkMode(isDarkModeOn: Bool) {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?
            .overrideUserInterfaceStyle = isDarkModeOn ? .dark : .light
    }
}

class UserDefaultsHelper {
    private static var userDefaults = UserDefaults.standard

    static func getCurrentCookie() throws -> Cookie? {
        let cookieName = userDefaults.string(forKey: UserDefaultsKey.CURRENT_COOKIE)
        if cookieName == nil {
            return nil
        }

        let cookie = try PersistenceController.shared.findCookieByName(name: cookieName!)

        return cookie
    }

    static func setCurrentCookie(currentCookieName: String) {
        userDefaults.set(currentCookieName, forKey: UserDefaultsKey.CURRENT_COOKIE)
    }

    static func removeCurrentCookie() {
        userDefaults.removeObject(forKey: UserDefaultsKey.CURRENT_COOKIE)
    }
}

class HapticsHelper {
    @AppStorage(UserDefaultsKey.HAPTIC_FEEDBACK)
    static var hapticFeedbackEnabled: Bool = false

    static func playHapticFeedback() {
        if (hapticFeedbackEnabled) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}
