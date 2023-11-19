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
                    img: "2022-10-24/63566a6945427",
                    ext: ".png",
                    now: "2023-10-27(五)18:06:14",
                    userHash: "BctQnao",
                    name: "无名氏",
                    title: "无标题",
                    // swiftlint:disable line_length
                    content: "欢迎来到X岛，一个半全新的（中老年）泛ACG讨论区<br><br>\n=============注册已开启=============<br>\n======本周饼干开启时间【周六日】======<br><br>\n我们的 微博：@X岛揭示板　微信公众号：<a href=\"https://image.nmb.best/image/2023-03-26/64205d7d702ca.png\">矛盾苇草</a><br>\n如您第一次使用本社区，建议您点击此文查看回复<br>\n否则我们不能保证其他用户对您的友善态度<br>\n客户端下载地址：<a href=\"https://app.nmbxd.com\" target=\"_blank\">https://app.nmbxd.com</a>",
                    // swiftlint:enable line_length
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
                    hide: 0)
    ]
}
