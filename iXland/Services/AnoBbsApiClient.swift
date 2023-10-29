import Foundation
import Combine
import Alamofire

final class AnoBbsApiClient {
    private static let logger = LoggerHelper.getLoggerForNetworkRequest(name: "AnoBbsApiClient")

    public static func getCdnPath(
        complete:@escaping ([CdnList]) -> Void,
        failure:@escaping (String) -> Void
    ) {
        logger.info("Loading CDN list")

        doRequest(url: XdnmbAPI.GET_CDN_LIST,
                  method: .get, 
                  complete: complete,
                  failure: failure)
    }

    /// 获取版面列表
    ///
    /// - Parameters:
    ///   - completion: 处理返回的`ForumGroup`列表的回调方法
    ///   - failure: 处理错误信息的回调方法
    public static func loadForumGroups(
        complete:@escaping ([ForumGroup]) -> Void,
        failure:@escaping (String) -> Void
    ) {
        logger.info("Loading forum groups")

        doRequest(url: XdnmbAPI.GET_FORUM_LIST,
                  method: .get,
                  complete: complete,
                  failure: failure)
    }

    private static func doRequest<T: Codable>(
        url: String,
        method: HTTPMethod,
        complete:@escaping (T) -> Void,
        failure:@escaping (String) -> Void
    ) {
        AF.request(url, method: method, interceptor: .retryPolicy) { request in request.timeoutInterval = 10 }
            .cacheResponse(using: .cache)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    complete(data)
                case .failure(let error):
                    failure(error.underlyingError?.localizedDescription ?? error.localizedDescription)
                }
            }
    }
}
