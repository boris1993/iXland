import Foundation
import Combine
import Alamofire

final class AnoBbsApiClient {
    private static let logger = LoggerHelper.getLoggerForNetworkRequest(name: "AnoBbsApiClient")

    public static func loadForumGroups(
        completion:@escaping ([ForumGroup]) -> Void,
        failure:@escaping (String) -> Void
    ) {
        let url = URL(string: XdnmbAPI.GET_FORUM_LIST)!
        AF.request(url, method: .get, interceptor: .retryPolicy) { $0.timeoutInterval = 10 }
            .cacheResponse(using: .cache)
            .validate()
            .responseDecodable(of: [ForumGroup].self) { response in
                switch response.result {
                case .success(let data):
                    completion(data)
                case .failure(let error):
                    failure(error.localizedDescription)
                }
            }
    }
}
