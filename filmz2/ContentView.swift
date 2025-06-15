//
//  ContentView.swift
//  filmz2
//
//  Created by Till Gartner on 29.05.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: MainTab = .collection

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
        }
        // Removed iCloudSyncAlert for seamless experience like filmz v1
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
