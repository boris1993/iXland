struct Constants {
    static let GitHubRepoAddress = "https://github.com/boris1993/iXland"
    static let CookieNameUserhash = "userhash"
}

struct UserDefaultsKey {
    static let Theme = "theme"
    static let SubscriptionID = "subscription-id"
    static let HapticFeedback = "haptic-feedback"
    static let CurrentCookie = "current-cookie"
}

enum Themes: String {
    case dark
    case light
}

struct XdnmbAPI {
    private static let _BaseURL = "https://www.nmbxd1.com"
    static let GetCDNList = "\(_BaseURL)/Api/getCdnPath"
    static let GetTimelineList = "\(_BaseURL)/Api/getTimelineList"
    static let GetForumList = "\(_BaseURL)/Api/getForumList"
    static let GetTimeline = "\(_BaseURL)/Api/Timeline"
}
