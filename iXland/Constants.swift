struct Constants {
    static let GITHUB_REPO_ADDRESS = "https://github.com/boris1993/iXland"
}

struct UserDefaultsKey {
    static let THEME = "theme"
    static let SUBSCRIPTION_ID = "subscription-id"
    static let HAPTIC_FEEDBACK = "haptic-feedback"
    static let CURRENT_COOKIE = "current-cookie"
}

enum Themes: String {
    case dark
    case light
}

struct XdnmbAPI {
    private static let BASE_URL = "https://www.nmbxd1.com"
    static let GET_CDN_LIST = "\(BASE_URL)/Api/getCdnPath"
    static let GET_TIMELINE_LIST = "\(BASE_URL)/Api/getTimelineList"
    static let GET_FORUM_LIST = "\(BASE_URL)/Api/getForumList"
}
