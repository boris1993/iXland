import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    @Published
    var currentSelectedCookie: Cookie? = try? UserDefaultsHelper.getCurrentCookie()
}
