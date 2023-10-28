import Foundation
import SwiftUI

final class GlobalState: ObservableObject {
    @Published
    var currentSelectedCookie: Cookie? = try? UserDefaultsHelper.getCurrentCookie()

    @Published
    var loadingStatus = ""

    @Published
    var cdnUrl = ""
}
