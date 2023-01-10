import SwiftUI
import CoreData

struct ContentView: View {
    private let persistenceController = PersistenceController.shared
    
    @Environment(\.managedObjectContext)
    var managedObjectContext
    
    @Environment(\.colorScheme)
    var systemColorScheme
    
    @State
    private var selectedTab = Tab.Timeline
    
    private enum Tab: String {
        case Timeline, Forums, Favourites, Settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("tabNameTimeline")
                }.tag(Tab.Timeline)
            ForumsView()
                .tabItem {
                    Image(systemName: "square.stack")
                    Text("tabNameForums")
                }.tag(Tab.Forums)
            FavouritesView()
                .tabItem {
                    Image(systemName: "star")
                    Text("tabNameFavourites")
                }.tag(Tab.Favourites)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("tabNameSettings")
                }.tag(Tab.Settings)
        }
        .onAppear() {
            let selectedTheme = UserDefaultsHelper.getSelectedTheme()
            
            if (selectedTheme != nil) {
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
                .environment(\.locale, Locale(identifier: "en"))
            ContentView()
                .previewDisplayName("zh-Hans")
                .environment(\.managedObjectContext, context)
                .environment(\.locale, Locale.init(identifier: "zh-Hans"))
        }
    }
}
