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
    private var shouldDisplayProgressView = true

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
