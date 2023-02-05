import SwiftUI
import CoreData

struct ContentView: View {
    private let logger = LoggerHelper.getLoggerForView(name: "ContentView")
    private let persistenceController = PersistenceController.shared

    @Environment(\.managedObjectContext)
    var managedObjectContext

    @Environment(\.colorScheme)
    var systemColorScheme

    @StateObject
    var globalState = GlobalState()

    @State
    private var selectedTab = Tab.Timeline

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
                
                if (globalState.isHapticFeedbackEnabled) {
                    HapticsHelper.playHapticFeedback()
                }
            })) {
            TimelineView()
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("Timeline")
                }
                .tag(Tab.Timeline)
            ForumsView()
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
            let selectedTheme = UserDefaultsHelper.getSelectedTheme()

            if selectedTheme != nil {
                let appTheme = Themes(rawValue: selectedTheme!)
                ThemeHelper.setAppTheme(themePickerSelectedValue: appTheme!)
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
