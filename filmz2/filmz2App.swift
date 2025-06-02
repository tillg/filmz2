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
            Item.self,
            MyFilm.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
