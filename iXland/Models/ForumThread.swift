import Foundation

struct ForumThread: Codable, Identifiable {
    var id: String
    var fid: Int
    var replyCount: Int
    var img: String
    var ext: String
    var now: String
    var userHash: String
    var name: String
    var title: String
    var content: String
    var sage: Int
    var admin: Int
    var hide: Int

    enum CodingKeys: String, CodingKey {
        case id
        case fid
        case replyCount
        case img
        case ext
        case now
        case userHash = "user_hash"
        case name
        case title
        case content
        case sage
        case admin
        case hide
    }
}
