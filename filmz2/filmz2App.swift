//
//  filmz2App.swift
//  filmz2
//
//  Created by Till Gartner on 29.05.25.
//

import SwiftUI
import SwiftData

@main
struct filmz2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MyFilm.self,
            IMDBFilm.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.com.grtnr.filmz2")
        )
        
        print("filmz2App: Initializing with CloudKit container: iCloud.com.grtnr.filmz2")

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("filmz2App: ModelContainer created successfully")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
