import SwiftUI
import GoogleMobileAds

@main
// swiftlint:disable type_name
struct iXlandApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        let gAdMobileSharedInstance = GADMobileAds.sharedInstance()

        #if DEBUG
            gAdMobileSharedInstance.requestConfiguration.testDeviceIdentifiers = ["e6e9d9a5b0e2a296db4657d9dcd13f2b"]
        #endif

        gAdMobileSharedInstance.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(GlobalState.shared)
        }
    }
}
// swiftlint:enable type_name
