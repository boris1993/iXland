import Foundation

struct TimelineForum: Codable, Identifiable {
    var id: Int
    var name: String
    var displayName: String
    var notice: String
    var maxPage: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName = "display_name"
        case notice
        case maxPage = "max_page"
    }

    public static var sample = [
        TimelineForum(id: 1,
                      name: "综合线",
                      displayName: "综合线",
                      notice: "主时间线",
                      maxPage: 20),
        TimelineForum(id: 2,
                      name: "创作线",
                      displayName: "创作线",
                      notice: "<b>包含创作类板块</b>",
                      maxPage: 20),
        TimelineForum(id: 3,
                      name: "非创作线",
                      displayName: "非创作线",
                      notice: "<b>本时间线不含综合一、欢乐恶搞及部分创作类板块</b>",
                      maxPage: 20),
    ]
}
