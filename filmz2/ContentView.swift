//
//  ContentView.swift
//  filmz2
//
//  Created by Till Gartner on 29.05.25.
//

import SwiftUI
import SwiftData
import CloudKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: MainTab = .collection
    @StateObject private var cloudKitChecker = CloudKitAvailabilityChecker()

    var body: some View {
        TabView(selection: $selectedTab) {
            CollectionView()
                .tabItem {
                    Label(MainTab.collection.title, 
                          systemImage: MainTab.collection.icon)
                }
                .tag(MainTab.collection)
            
            MovieSearchView(searchService: OMDBServiceFactory.createSearchService())
            .tabItem {
                Label(MainTab.search.title, 
                      systemImage: MainTab.search.icon)
            }
            .tag(MainTab.search)
            
            SettingsView()
                .tabItem {
                    Label(MainTab.settings.title, 
                          systemImage: MainTab.settings.icon)
                }
                .tag(MainTab.settings)
        }
        .onAppear {
            // Initialize managers with the shared context
            MyFilmsManager.shared.setModelContext(modelContext)
            // CacheManager is deprecated - replaced by IMDBFilmManager actor
            
            // Perform CloudKit availability check
            // This makes direct CloudKit API calls that trigger iOS system prompts
            // for iCloud login when necessary (mimicking old filmz behavior)
            Task {
                await cloudKitChecker.checkCloudKitAvailability()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
