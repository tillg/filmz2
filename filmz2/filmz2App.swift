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
            cloudKitDatabase: .private(AppConfig.Services.cloudKitContainer)
        )
        
        print("filmz2App: Initializing with CloudKit container: \(AppConfig.Services.cloudKitContainer)")

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("filmz2App: ModelContainer created successfully")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Configure services with dependency injection
        configureServices()
    }
    
    private func configureServices() {
        // Create IMDBFilmManager with the shared model container
        let filmManager = IMDBFilmManager(modelContainer: sharedModelContainer)
        
        // Configure OMDBSearchService with the film manager
        OMDBSearchService.setSharedFilmManager(filmManager)
        
        print("filmz2App: Services configured with IMDBFilmManager")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
