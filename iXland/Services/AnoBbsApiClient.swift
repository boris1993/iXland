import Foundation
import Combine
import Alamofire

final class AnoBbsApiClient {
    private static let logger = LoggerHelper.getLoggerForNetworkRequest(name: "AnoBbsApiClient")

    public static func loadForumGroups(completion:@escaping ([ForumGroup]) -> Void) {
        let url = URL(string: XdnmbAPI.GET_FORUM_LIST)!
        AF.request(url, method: .get, interceptor: .retryPolicy)
            .cacheResponse(using: .cache)
            .validate()
            .responseDecodable(of: [ForumGroup].self) { response in
                guard let forumGroups = response.value else {
                    print(String(describing: response.error))
                    return
                }
                completion(forumGroups)
            }
    }
}
