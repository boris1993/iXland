import SwiftUI
import AlertToast

struct ForumsView: View {
    private let logger = LoggerHelper.getLoggerForView(name: "ContentView")
    private let persistenceController = PersistenceController.shared

    @StateObject
    var globalState = GlobalState()

    @Binding
    var shouldDisplayProgressView: Bool

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Environment(\.colorScheme)
    private var systemColorScheme

    @Binding
    var forumGroups: [ForumGroup]

    var body: some View {
        NavigationStack {
            List ($forumGroups) { $forumGroup in
                Section {
                    ForEach(forumGroup.forums) { forum in
                        NavigationLink(destination: CookieListView(globalState: globalState)) {
                            Text(forum.name)
                        }
                    }
                } header: {
                    Text(forumGroup.name)
                        .font(.title3)
                }
            }
            .opacity(forumGroups.isEmpty ? 0 : 1)
        }
    }
}

struct ForumsView_Previews: PreviewProvider {
    @ObservedObject
    static var globalState = GlobalState()

    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        ForumsView(globalState: globalState, shouldDisplayProgressView: .constant(false), forumGroups: .constant(ForumGroup.sample))
            .previewDisplayName("en")
            .environment(\.managedObjectContext, context)
            .environment(\.colorScheme, .dark)
            .environment(\.locale, .init(identifier: "en"))
        ForumsView(globalState: globalState, shouldDisplayProgressView: .constant(false), forumGroups: .constant(ForumGroup.sample))
            .previewDisplayName("zh-Hans")
            .environment(\.managedObjectContext, context)
            .environment(\.colorScheme, .dark)
            .environment(\.locale, .init(identifier: "zh-Hans"))
    }
}
