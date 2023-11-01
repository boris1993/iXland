import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    @Published
    var currentSelectedCookie: Cookie? = try? UserDefaultsHelper.getCurrentCookie()

    @Published
    var cdnUrl = ""

    @Published
    var forumIdAndNameDictionary: [String:String] = [:]
}
