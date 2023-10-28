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

    @State
    private var isErrorToastShowing = false

    @State
    private var errorMessage: String = ""

    @State
    private var isContentLoaded = false

    @State
    var forumGroups = [ForumGroup]()

    var body: some View {
        NavigationStack {
            List {
                ForEach($forumGroups) { $forumGroup in
                    Section {
                        ForEach(forumGroup.forums) { forum in
                            NavigationLink(destination: CookieListView(globalState: globalState)) {
                                if (forum.showName == nil || forum.showName!.isEmpty) {
                                    Text(forum.name)
                                } else {
                                    Text(forum.showName!)
                                }
                            }
                        }
                    } header: {
                        Text(forumGroup.name)
                    }
                }
            }
        }
        .onAppear {
            if (!isContentLoaded) {
                globalState.loadingStatus = String(localized: "msgLoadingForumList");
                shouldDisplayProgressView = true;

                AnoBbsApiClient.loadForumGroups { forumGroups in
                    self.forumGroups = forumGroups
                    isContentLoaded = true
                    shouldDisplayProgressView = false;
                } failure: { error in
                    showErrorToast(message: error)
                    shouldDisplayProgressView = false;
                }
            }
        }
        .toast(isPresenting: $isErrorToastShowing) {
            AlertToast(type: .regular, title: errorMessage)
        }
    }

    private func showErrorToast(message: String) {
        errorMessage = message
        isErrorToastShowing = true
    }
}

struct ForumsView_Previews: PreviewProvider {
    @ObservedObject
    static var globalState = GlobalState()

    struct Container: View {
        @State
        private var forumGroups = ForumGroup.sample

        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            ForumsView(globalState: globalState, shouldDisplayProgressView: .constant(false), forumGroups: forumGroups)
                .previewDisplayName("en")
                .environment(\.managedObjectContext, context)
                .environment(\.colorScheme, .dark)
                .environment(\.locale, .init(identifier: "en"))
            ForumsView(globalState: globalState, shouldDisplayProgressView: .constant(false), forumGroups: forumGroups)
                .previewDisplayName("zh-Hans")
                .environment(\.managedObjectContext, context)
                .environment(\.colorScheme, .dark)
                .environment(\.locale, .init(identifier: "zh-Hans"))
        }
    }

    static var previews: some View {
        Container()
    }
}
