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
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.overrideUserInterfaceStyle = isDarkModeOn ? .dark : .light
    }
}

class UserDefaultsHelper {
    private static var userDefaults = UserDefaults.standard
    
    static func getSelectedTheme() -> String? {
        return userDefaults.string(forKey: UserDefaultsKey.THEME)
    }
    
    static func setSelectedTheme(theme: String) {
        userDefaults.set(theme, forKey: UserDefaultsKey.THEME)
    }
    
    static func getSubscriptionId() -> String {
        return userDefaults.string(forKey: UserDefaultsKey.SUBSCRIPTION_ID) ?? ""
    }
    
    static func setSubscriptionId(subscriptionId: String) {
        userDefaults.set(subscriptionId, forKey: UserDefaultsKey.SUBSCRIPTION_ID)
    }
    
    static func getHapticFeedbackEnabledState() -> Bool {
        return userDefaults.bool(forKey: UserDefaultsKey.HAPTIC_FEEDBACK)
    }
    
    static func setHapticFeedbackEnabledState(isHapticFeedbackEnabled: Bool) {
        userDefaults.set(isHapticFeedbackEnabled, forKey: UserDefaultsKey.HAPTIC_FEEDBACK)
    }
    
    static func getCurrentCookie() throws -> Cookie? {
        let cookieName = userDefaults.string(forKey: UserDefaultsKey.CURRENT_COOKIE)
        if (cookieName == nil) {
            return nil
        }
        
        let cookie = try PersistenceController.shared.findCookieByName(name: cookieName!)
        
        return cookie
    }
    
    static func setCurrentCookie(currentCookieName: String) throws {
        userDefaults.set(currentCookieName, forKey: UserDefaultsKey.CURRENT_COOKIE)
    }
}

class HapticsHelper {
    static func playHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
