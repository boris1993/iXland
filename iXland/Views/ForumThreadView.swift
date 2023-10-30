import Foundation
import SwiftUI

struct ForumThreadView: View {
    let logger = LoggerHelper.getLoggerForView(name: "ForumThreadView")

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Binding
    var forumThread: ForumThread

    @Binding
    var forumIdAndNameDictionary: [String:String]

    @StateObject
    var globalState = GlobalState()

    var body: some View {
        VStack(spacing: 5) {
            VStack {
                HStack {
                    if (forumThread.sage == 1) {
                        Image(systemName: "arrowshape.down.fill")
                            .foregroundColor(.red)
                    }

                    Text("\(forumThread.id)")

                    if (forumThread.admin == 1) {
                        Text(forumThread.userHash).bold().foregroundStyle(.red)
                    } else {
                        Text(forumThread.userHash).bold()
                    }

                    let forumName = self.forumIdAndNameDictionary["\(forumThread.fid)"]
                    Text(forumName ?? "无此版面").frame(maxWidth: .infinity, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(forumThread.now).frame(maxWidth: .infinity, alignment: .leading)

                if (forumThread.title != "无标题") {
                    Text("标题：\(forumThread.title)").frame(maxWidth: .infinity, alignment: .leading)
                }

                if (forumThread.name != "无名氏") {
                    Text("作者：\(forumThread.name)").frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Divider()

            Text(forumThread.content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
    }
}

struct ForumThreadView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleData = ForumThread(id: 54961581,
                                     fid: 4,
                                     replyCount: 6,
                                     img: "",
                                     ext: "",
                                     now: "2023-01-19(四)23:27:29",
                                     userHash: "KXFkoBO",
                                     name: "作者",
                                     title: "标题",
                                     content: "测试串内容\n测试串内容",
                                     sage: 1,
                                     admin: 1,
                                     hide: 0)

        ForumThreadView(
            forumThread: .constant(sampleData),
            forumIdAndNameDictionary: .constant(["4": "综合版一"])
        )
        .environment(\.managedObjectContext, context)
    }
}
