import Foundation

public enum AppError: Error {
case invalidQrCodeResultCount(rawData: String)
case runtimeError(message: String)
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidQrCodeResultCount(rawData: let rawData):
            return String(
                format: NSLocalizedString("msgInvalidCookieQrCode", comment: ""),
                NSLocalizedString(rawData, comment: ""))
        case .runtimeError(message: let message):
            return message
        }
    }
}
