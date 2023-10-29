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
    private var initialized = false

    @State
    private var shouldDisplayProgressView = false

    @State
    private var failedLoadingContent = true

    @State
    private var errorMessage: [String] = ["aaa", "bbb"]

    @AppStorage(UserDefaultsKey.THEME)
    private var themePickerSelectedValue: Themes = Themes.dark

    private enum Tab: String {
        case Timeline, Forums, Favourites, Settings
    }

    var body: some View {
        VStack {
            if (initialized) {
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
                        ForumsView(globalState: globalState, shouldDisplayProgressView: $shouldDisplayProgressView)
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
                            .onAppear {
                                shouldDisplayProgressView = false
                            }
                    }
                    .onAppear {
                        let selectedTheme = themePickerSelectedValue.rawValue
                        let appTheme = Themes(rawValue: selectedTheme)
                        ThemeHelper.setAppTheme(themePickerSelectedValue: appTheme!)
                    }
                    .overlay {
                        if (shouldDisplayProgressView) {
                            ProgressView {
                                Text(globalState.loadingStatus)
                            }
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaledToFill()
                        } else {
                            EmptyView()
                        }
                    }
            } else if (failedLoadingContent) {
                VStack {
                    Text("msgFailedLoadingForumList")
                    Text(errorMessage.joined(separator: "\n"))
                    Text("msgTapToRetry")
                }
                .onTapGesture {
                    failedLoadingContent = false
                    errorMessage = []
                    initialize()
                }
            }
        }
        .onAppear {
            initialize()
        }
        .overlay {
            if (!initialized && !failedLoadingContent) {
                ProgressView {
                    Text(globalState.loadingStatus)
                }
                .progressViewStyle(CircularProgressViewStyle())
                .scaledToFill()
            }
        }
    }

    private func initialize() {
        getCdnPath()
        initialized = true
    }

    private func getCdnPath() {
        globalState.loadingStatus = String(localized: "msgLoadingCdnList")
        AnoBbsApiClient.getCdnPath { cdnList in
            globalState.cdnUrl = cdnList.sorted { $0.rate > $1.rate }.first!.url
            logger.debug("CDN URL set. Value = \(globalState.cdnUrl)")
        } failure: { error in
            failedLoadingContent = true
            errorMessage.append("msgFailedToLoadCdnList - \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        Group {
            ContentView()
                .previewDisplayName("en")
                .environment(\.managedObjectContext, context)
                .environment(\.colorScheme, .dark)
                .environment(\.locale, Locale(identifier: "en"))
            ContentView()
                .previewDisplayName("zh-Hans")
                .environment(\.managedObjectContext, context)
                .environment(\.colorScheme, .dark)
                .environment(\.locale, Locale.init(identifier: "zh-Hans"))
        }
    }
}
