import Foundation

struct ForumThread: Codable, Identifiable {
    var id: Int
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
        case replyCount = "ReplyCount"
        case img
        case ext
        case now
        case userHash = "user_hash"
        case name
        case title
        case content
        case sage
        case admin
        case hide = "Hide"
    }

    public static var sample = [
        ForumThread(id: 59976803,
                    fid: 4,
                    replyCount: 30,
                    img: "",
                    ext: "",
                    now: "2023-10-27(五)18:06:14",
                    userHash: "BctQnao",
                    name: "无名氏",
                    title: "无标题",
                    content: "测试内容",
                    sage: 1,
                    admin: 0,
                    hide: 0),
        ForumThread(id: 59976804,
                    fid: 4,
                    replyCount: 30,
                    img: "",
                    ext: "",
                    now: "2023-10-27(五)18:06:14",
                    userHash: "BctQnao",
                    name: "作者",
                    title: "无标题",
                    content: "测试内容",
                    sage: 1,
                    admin: 0,
                    hide: 0),
        ForumThread(id: 59976805,
                    fid: 4,
                    replyCount: 30,
                    img: "",
                    ext: "",
                    now: "2023-10-27(五)18:06:14",
                    userHash: "BctQnao",
                    name: "无名氏",
                    title: "标题",
                    content: "测试内容",
                    sage: 1,
                    admin: 0,
                    hide: 0),
        ForumThread(id: 59976806,
                    fid: 4,
                    replyCount: 30,
                    img: "",
                    ext: "",
                    now: "2023-10-27(五)18:06:14",
                    userHash: "BctQnao",
                    name: "作者",
                    title: "标题",
                    content: "测试内容",
                    sage: 1,
                    admin: 0,
                    hide: 0),
    ]
}
