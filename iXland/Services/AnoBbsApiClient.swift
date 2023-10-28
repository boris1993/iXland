import Foundation
import Combine
import Alamofire

final class AnoBbsApiClient {
    private static let logger = LoggerHelper.getLoggerForNetworkRequest(name: "AnoBbsApiClient")

    /// 获取版面列表
    ///
    /// - Parameters:
    ///   - completion: 处理返回的`ForumGroup`列表的回调方法
    ///   - failure: 处理错误信息的回调方法
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
