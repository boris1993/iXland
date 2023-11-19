import Foundation

struct ForumGroup: Codable, Identifiable {
    var id: String
    var sort: String
    var name: String
    var status: String
    var forums: [Forum]

    private enum CodingKeys: String, CodingKey {
        case id
        case sort
        case name
        case status
        case forums
    }

    static var sample = [ForumGroup](
        arrayLiteral: ForumGroup(id: "4", sort: "1", name: "综合", status: "n", forums: [
            Forum(id: "-1",
                  name: "时间线",
                  msg: "这里是匿名版最新的串"),
            Forum(id: "4",
                  fGroup: "4",
                  sort: "2",
                  name: "综合版1",
                  showName: "",
                  msg: "欢迎回来",
                  interval: "30",
                  threadCount: "62045",
                  permissionLevel: "0",
                  forumFuseId: "0",
                  createdAt: "2011-10-21 15:49:28",
                  updateAt: "2011-10-21 15:49:28",
                  status: "n")
        ])
    )
}

struct Forum: Codable, Identifiable {
    var id: String
    var fGroup: String?
    var sort: String?
    var name: String
    var showName: String?
    var msg: String
    var interval: String?
    var threadCount: String?
    var permissionLevel: String?
    var forumFuseId: String?
    var createdAt: String?
    var updateAt: String?
    var status: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case fGroup
        case sort
        case name
        case showName
        case msg
        case interval
        case threadCount = "thread_count"
        case permissionLevel = "permission_level"
        case forumFuseId = "forum_fuse_id"
        case createdAt
        case updateAt
        case status
    }
}
