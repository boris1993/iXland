import Foundation
import SwiftUI

class GlobalState: ObservableObject {
    public static let shared = GlobalState()

    @Published
    public var currentSelectedCookie: Cookie? = try? UserDefaultsHelper.getCurrentCookie()

    @Published
    public var cdnUrl = ""

    @Published
    public var forumIdAndNameDictionary = [String:String]()
}
