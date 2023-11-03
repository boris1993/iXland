import Foundation
import Combine
import Alamofire

final class AnoBbsApiClient {
    private static let logger = LoggerHelper.getLoggerForNetworkRequest(name: "AnoBbsApiClient")

    public static func getCdnPath() async throws -> [CdnList] {
        logger.info("Loading CDN list")
        return try await doRequest(url: XdnmbAPI.GET_CDN_LIST, method: .get)
    }

    /// 获取版面列表
    ///
    /// - Parameters:
    ///   - completion: 处理返回的`ForumGroup`列表的回调方法
    ///   - failure: 处理错误信息的回调方法
    public static func loadForumGroups() async throws -> [ForumGroup] {
        logger.info("Loading forum groups")
        return try await doRequest(url: XdnmbAPI.GET_FORUM_LIST, method: .get)
    }

    public static func loadTimelineForums() async throws -> [TimelineForum] {
        logger.info("Loading timeline forums")
        return try await doRequest(url: XdnmbAPI.GET_TIMELINE_LIST, method: .get)
    }

    public static func loadTimelineThreads(id: Int) async throws -> [ForumThread] {
        logger.info("Loading timeline")
        return try await doRequest(url: "\(XdnmbAPI.GET_TIMELINE)?id=\(id)&page=1", method: .get, useCache: false)
    }

    private static func doRequest<T: Codable>(
        url: String,
        method: HTTPMethod,
        timeout: Double = 10,
        useCache: Bool = true
    ) async throws -> T {
        let jsonDecoder = JSONDecoder()
        let request = AF
            .request(url, method: method, interceptor: .retryPolicy) { request in request.timeoutInterval = timeout }
            .validate(statusCode: 200..<299)

        if (useCache) {
            request.cacheResponse(using: .cache)
        }

        let task = request.serializingString()
        let result = await task.result
        switch result {
        case .success(let data):
            do {
                let response = try jsonDecoder.decode(T.self, from: data.data(using: .utf8)!)
                logger.info("Successfully decoded the response JSON to type \(T.self)")
                return response
            } catch DecodingError.typeMismatch {
                let errorResponse = try jsonDecoder.decode(AnoBbsSiteError.self, from: data.data(using: .utf8)!)
                logger.warning("Failed to decode the JSON response. Raw value is: \(errorResponse.error)")
                throw AppError.RuntimeError(message: errorResponse.error)
            } catch let error {
                throw AppError.RuntimeError(message: error.localizedDescription)
            }
        case .failure(let error):
            throw AppError.RuntimeError(message: error.underlyingError?.localizedDescription ?? error.localizedDescription)
        }
    }
}
