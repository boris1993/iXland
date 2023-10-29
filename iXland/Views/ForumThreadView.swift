import Foundation
import SwiftUI

struct ForumThreadView: View {
    let logger = LoggerHelper.getLoggerForView(name: "ForumThreadView")

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Binding
    var forumThread: ForumThread

    @StateObject
    var globalState = GlobalState()

    var body: some View {
        VStack(spacing: 5) {
            VStack {
                HStack {
                    HStack {
                        Text(forumThread.id)

                        if (forumThread.admin == 1) {
                            Text(forumThread.userHash).foregroundStyle(.red)
                        } else {
                            Text(forumThread.userHash)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        if (forumThread.sage == 1) {
                            Text("SAGE")
                                .foregroundStyle(.red)
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)

                }

                HStack {
                    let forumName = globalState.forumIdAndNameDictionary["\(forumThread.fid)"]
                    Text(forumName ?? "无此版面")
                    Text(forumThread.now).frame(maxWidth: .infinity, alignment: .trailing)
                }
            }

            Divider()

            Text(forumThread.content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

struct ForumThreadView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleData = ForumThread(id: "54961581",
                                     fid: 4,
                                     replyCount: 6,
                                     img: "",
                                     ext: "",
                                     now: "2023-01-19(四)23:27:29",
                                     userHash: "KXFkoBO",
                                     name: "无名氏",
                                     title: "无标题",
                                     content: "测试串内容\n测试串内容",
                                     sage: 1,
                                     admin: 1,
                                     hide: 0)

        ForumThreadView(forumThread: .constant(sampleData))
            .environment(\.managedObjectContext, context)
    }
}
