import Foundation
import SwiftUI

struct ForumThreadView: View {
    let logger = LoggerHelper.getLoggerForView(name: "ForumThreadView")

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    var geometry: GeometryProxy

    @Binding
    var forumThread: ForumThread

    @Binding
    var forumIdAndNameDictionary: [String:String]

    @Binding
    var cdnUrl: String

    var body: some View {
        VStack(spacing: 5) {
            VStack {
                HStack {
                    if (forumThread.sage == 1) {
                        Image(systemName: "arrowshape.down.fill")
                            .foregroundColor(.red)
                    }

                    Text(verbatim: "\(forumThread.id)").foregroundStyle(.orange).brightness(-0.1)

                    if (forumThread.admin == 1) {
                        Text(forumThread.userHash).bold().foregroundStyle(.red)
                    } else {
                        Text(forumThread.userHash).bold().foregroundStyle(.orange).brightness(-0.1)
                    }

                    let forumName = self.forumIdAndNameDictionary["\(forumThread.fid)"]!
                    Text(forumName).frame(maxWidth: .infinity, alignment: .trailing)
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

            HStack(alignment: .top) {
                if (!forumThread.img.isEmpty) {
                    let url = URL(string: "\(cdnUrl)/image/\(forumThread.img)\(forumThread.ext)")
                    AsyncImage(url: url) { image in
                        image.image?
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(maxWidth: geometry.size.width * 0.2, alignment: .topLeading)
                }

                Text(forumThread.content)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .font(.subheadline)
    }
}

struct ForumThreadView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleData = ForumThread.sample[0]

        GeometryReader { geometry in
            ForumThreadView(
                geometry: geometry,
                forumThread: .constant(sampleData),
                forumIdAndNameDictionary: .constant(["4": "综合版一"]),
                cdnUrl: .constant("https://image.nmb.best/")
            )
        }
        .environment(\.managedObjectContext, context)
    }
}
