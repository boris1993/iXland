import Foundation
import SwiftUI

class ForumThreadViewModel {
    var id: String
    var cookie: String
    var title: String
    var author: String
    var now: String
    var content: String

    init(id: String, cookie: String, title: String, author: String, now: String, content: String) {
        self.id = id
        self.cookie = cookie
        self.title = title
        self.author = author
        self.now = now
        self.content = content
    }
}

struct ForumThreadView: View {
    let logger = LoggerHelper.getLoggerForView(name: "ForumThreadView")

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Binding
    var forumThread: ForumThread

    var body: some View {
        VStack {
            HStack{
                Text(forumThread.id)
                if (forumThread.admin == 1) {
                    Text(forumThread.userHash).foregroundStyle(.red)
                } else {
                    Text(forumThread.userHash)
                }
                Text(forumThread.now).frame(maxWidth: .infinity, alignment: .trailing)

            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(forumThread.content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 5)
            
            if (forumThread.sage == 1) {
                Text("SAGE")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
