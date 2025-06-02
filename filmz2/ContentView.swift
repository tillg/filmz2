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
    @StateObject private var myFilmsStore: MyFilmsStore
    @State private var selectedTab: MainTab = .collection
    
    init() {
        // Create a temporary store - will be replaced with proper context
        let tempContainer = try! ModelContainer(for: MyFilm.self)
        let tempContext = ModelContext(tempContainer)
        self._myFilmsStore = StateObject(wrappedValue: MyFilmsStore(modelContext: tempContext))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CollectionView()
                .tabItem {
                    Label(MainTab.collection.title, 
                          systemImage: MainTab.collection.icon)
                }
                .tag(MainTab.collection)
            
            MovieSearchView()
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
        .environment(\.myFilmsStore, myFilmsStore)
        .onAppear {
            // Update the store with the actual model context
            myFilmsStore.modelContext = modelContext
            myFilmsStore.fetchFilms()
            
            // Set model context for OMDBSearchService
            OMDBSearchService.shared.setModelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
