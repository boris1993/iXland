//
//  iXlandApp.swift
//  iXland
//
//  Created by Boris Zhao on 2023-01-01.
//

import SwiftUI

@main
struct iXlandApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
