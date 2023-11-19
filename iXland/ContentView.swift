import SwiftUI
import CoreData

struct ContentView: View {
    private let logger = LoggerHelper.getLoggerForView(name: "ContentView")
    private let persistenceController = PersistenceController.shared

    @EnvironmentObject
    var globalState: GlobalState

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Environment(\.colorScheme)
    private var systemColorScheme

    @State
    private var selectedTab = Tab.timeline

    @State
    private var shouldDisplayProgressView = false

    @State
    private var progressViewText = ""

    @State
    private var loadCdnUrlFinished = false

    @State
    private var loadForumListFinished = false

    @State
    private var errorMessage: [String] = []

    @State
    var forumGroups: [ForumGroup] = []

    @AppStorage(UserDefaultsKey.Theme)
    private var themePickerSelectedValue: Themes = Themes.dark

    private enum Tab: String {
        case timeline, forums, favourites, settings
    }

    var body: some View {
        ZStack {
            if loadCdnUrlFinished && loadForumListFinished {
                TabView(selection: .init(
                    get: {
                        selectedTab
                    },
                    set: { newTab in
                        selectedTab = newTab
                        HapticsHelper.playHapticFeedback()
                    })) {
                        TimelineView()
                            .environmentObject(globalState)
                            .tabItem {
                                Image(systemName: "calendar.day.timeline.left")
                                Text("Timeline")
                            }
                            .tag(Tab.timeline)
                        ForumsView(
                            globalState: globalState,
                            shouldDisplayProgressView: $shouldDisplayProgressView,
                            forumGroups: $forumGroups
                        )
                        .tabItem {
                            Image(systemName: "square.stack")
                            Text("Forums")
                        }
                        .tag(Tab.forums)
                        FavouritesView()
                            .tabItem {
                                Image(systemName: "star")
                                Text("Favourites")
                            }
                            .tag(Tab.favourites)
                        SettingsView(globalState: globalState)
                            .tabItem {
                                Image(systemName: "gear")
                                Text("Settings")
                            }
                            .tag(Tab.settings)
                    }
                    .onAppear {
                        logger.info("Displaying the TabView")
                        let tabBarAppearance = UITabBarAppearance()
                        tabBarAppearance.configureWithDefaultBackground()
                        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                    }
            } else {
                VStack {
                    // MARK: 显示初始化状态的ProgressView
                    ProgressView {
                        Text("msgInitializing")
                    }
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaledToFill()
                    .onAppear {
                        logger.info("Displaying the initializing indicator")
                        Task {
                            await initialize()
                        }
                    }
                    .opacity(errorMessage.isEmpty ? 1 : 0)

                    VStack {
                        Text("msgFailedLoadingForumList")
                        Text(errorMessage.joined(separator: "\n"))
                        Text("msgTapToRetry")
                    }
                    .onTapGesture {
                        errorMessage = []
                        Task {
                            await initialize()
                        }

                    }
                    .opacity(errorMessage.isEmpty ? 0 : 1)
                }
            }
        }
        .onAppear {
            let selectedTheme = themePickerSelectedValue.rawValue
            let appTheme = Themes(rawValue: selectedTheme)
            ThemeHelper.setAppTheme(themePickerSelectedValue: appTheme!)
        }
    }

    private func initialize() async {
        await getCdnPath()
        await initializeForums()
    }

    private func getCdnPath() async {
        loadCdnUrlFinished = false
        do {
            let cdnList = try await AnoBbsApiClient.getCdnPath()
            globalState.cdnUrl = cdnList.sorted { $0.rate > $1.rate }.first!.url
            loadCdnUrlFinished = true
        } catch let error {
            errorMessage.append("\(String(localized: "msgFailedToLoadCdnList")) - \(error)")
        }
    }

    private func initializeForums() async {
        loadForumListFinished = false
        do {
            self.forumGroups = try await AnoBbsApiClient.loadForumGroups()
            self.forumGroups.forEach { forumGroup in
                forumGroup.forums.forEach { forum in
                    globalState.forumIdAndNameDictionary[forum.id] = forum.name
                }
            }
            loadForumListFinished = true
        } catch let error {
            errorMessage.append("\(String(localized: "msgFailedToLoadForums")) - \(error)")
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
