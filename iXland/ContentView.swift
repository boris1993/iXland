import SwiftUI
import CoreData

struct ContentView: View {
    private let logger = LoggerHelper.getLoggerForView(name: "ContentView")
    private let persistenceController = PersistenceController.shared

    @StateObject
    var globalState = GlobalState()

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Environment(\.colorScheme)
    private var systemColorScheme

    @State
    private var selectedTab = Tab.Timeline

    @State
    private var shouldDisplayProgressView = false

    @State
    private var loadCdnUrlFinished = false

    @State
    private var loadForumListFinished = false

    @State
    private var errorMessage: [String] = []

    @State
    var forumGroups: [ForumGroup] = []

    @AppStorage(UserDefaultsKey.THEME)
    private var themePickerSelectedValue: Themes = Themes.dark

    private enum Tab: String {
        case Timeline, Forums, Favourites, Settings
    }

    var body: some View {
        TabView(selection: .init(
            get: {
                selectedTab
            },
            set: { newTab in
                selectedTab = newTab
                HapticsHelper.playHapticFeedback()
            })) {
                TimelineView()
                    .tabItem {
                        Image(systemName: "calendar.day.timeline.left")
                        Text("Timeline")
                    }
                    .tag(Tab.Timeline)
                ForumsView(globalState: globalState, shouldDisplayProgressView: $shouldDisplayProgressView, forumGroups: $forumGroups)
                    .tabItem {
                        Image(systemName: "square.stack")
                        Text("Forums")
                    }
                    .tag(Tab.Forums)
                FavouritesView()
                    .tabItem {
                        Image(systemName: "star")
                        Text("Favourites")
                    }
                    .tag(Tab.Favourites)
                SettingsView(globalState: globalState)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(Tab.Settings)
            }
            .onAppear {
                let selectedTheme = themePickerSelectedValue.rawValue
                let appTheme = Themes(rawValue: selectedTheme)
                ThemeHelper.setAppTheme(themePickerSelectedValue: appTheme!)
            }
            .task {
                initialize()
            }
            .overlay {
                // MARK: 显示初始化状态的ProgressView
                ProgressView {
                    Text("msgInitializing")
                }
                .progressViewStyle(CircularProgressViewStyle())
                .scaledToFill()
                .opacity(loadCdnUrlFinished && loadForumListFinished ? 0 : 1)

                VStack {
                    Text("msgFailedLoadingForumList")
                    Text(errorMessage.joined(separator: "\n"))
                    Text("msgTapToRetry")
                }
                .onTapGesture {
                    errorMessage = []
                    initialize()
                }
                .opacity(errorMessage.isEmpty ? 0 : 1)
            }
    }

    private func initialize() {
        getCdnPath()
        initializeForums()
    }

    private func getCdnPath() {
        loadCdnUrlFinished = false
        AnoBbsApiClient.getCdnPath { cdnList in
            globalState.cdnUrl = cdnList.sorted { $0.rate > $1.rate }.first!.url
            loadCdnUrlFinished = true
        } failure: { error in
            errorMessage.append("\(String(localized: "msgFailedToLoadCdnList")) - \(error)")
            loadCdnUrlFinished = true
        }
    }

    private func initializeForums() {
        loadForumListFinished = false
        AnoBbsApiClient.loadForumGroups { forumGroups in
            self.forumGroups = forumGroups
            self.forumGroups.forEach { forumGroup in
                globalState.forumIdAndNameDictionary[forumGroup.id] = forumGroup.name
            }

            loadForumListFinished = true
        } failure: { error in
            errorMessage.append("\(String(localized: "msgFailedToLoadForums")) - \(error)")
            loadForumListFinished = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        Group {
            ContentView(forumGroups: ForumGroup.sample)
                .previewDisplayName("en")
                .environment(\.managedObjectContext, context)
                .environment(\.colorScheme, .dark)
                .environment(\.locale, Locale(identifier: "en"))
            ContentView(forumGroups: ForumGroup.sample)
                .previewDisplayName("zh-Hans")
                .environment(\.managedObjectContext, context)
                .environment(\.colorScheme, .dark)
                .environment(\.locale, Locale.init(identifier: "zh-Hans"))
        }
    }
}
