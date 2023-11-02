import Foundation

public enum AppError: Error {
case InvalidQrCodeResultCount(rawData: String)
case RuntimeError(message: String)
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .InvalidQrCodeResultCount(rawData: let rawData):
            return String(
                format: NSLocalizedString("msgInvalidCookieQrCode", comment: ""),
                NSLocalizedString(rawData, comment: ""))
        case .RuntimeError(message: let message):
            return message
        }
    }
}
