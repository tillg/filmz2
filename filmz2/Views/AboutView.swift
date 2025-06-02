//
//  AboutView.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI

struct AboutView: View {
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .cornerRadius(26)
                        .shadow(radius: 10)
                    
                    Text("Filmz2")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            Section("Developer") {
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("Till Gartner")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Built with")
                    Spacer()
                    Text("SwiftUI & SwiftData")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Information") {
                Link(destination: URL(string: "https://github.com/tillg/filmz2")!) {
                    HStack {
                        Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://www.omdbapi.com")!) {
                    HStack {
                        Label("Powered by OMDb API", systemImage: "network")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Legal") {
                Link(destination: URL(string: "https://example.com/privacy")!) {
                    HStack {
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://example.com/terms")!) {
                    HStack {
                        Text("Terms of Service")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("About")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}