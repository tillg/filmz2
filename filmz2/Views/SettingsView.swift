//
//  SettingsView.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                    }
                }
                
                Section("Developer") {
                    NavigationLink(destination: CacheView()) {
                        Label("Cache", systemImage: "internaldrive")
                    }
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

#Preview {
    SettingsView()
}