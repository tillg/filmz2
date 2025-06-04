//
//  SyncStatusView.swift
//  filmz2
//
//  Created by Till Gartner on 03.06.25.
//

import SwiftUI
import CoreData
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SyncStatusView: View {
    @State private var syncStatus: SyncStatus = .unknown
    @State private var showingDetail = false
    @State private var lastSyncDate: Date?
    @State private var syncError: String?
    
    enum SyncStatus {
        case unknown
        case syncing
        case synced
        case error
        case offline
        
        var iconName: String {
            switch self {
            case .unknown:
                return "icloud.slash"
            case .syncing:
                return "arrow.triangle.2.circlepath.icloud"
            case .synced:
                return "checkmark.icloud"
            case .error:
                return "exclamationmark.icloud"
            case .offline:
                return "icloud.slash"
            }
        }
        
        var color: Color {
            switch self {
            case .unknown:
                return .gray
            case .syncing:
                return .blue
            case .synced:
                return .green
            case .error:
                return .red
            case .offline:
                return .orange
            }
        }
        
        var description: String {
            switch self {
            case .unknown:
                return "Sync status unknown"
            case .syncing:
                return "Syncing..."
            case .synced:
                return "Synced"
            case .error:
                return "Sync error"
            case .offline:
                return "Sign in to iCloud"
            }
        }
    }
    
    var body: some View {
        Button(action: { showingDetail.toggle() }) {
            Image(systemName: syncStatus.iconName)
                .foregroundColor(syncStatus.color)
                .font(.system(size: 18))
                .symbolEffect(.pulse, isActive: syncStatus == .syncing)
                .opacity(syncStatus == .synced ? 0.6 : 1.0) // More subtle when synced
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .help(syncStatus.description)
        #endif
        .sheet(isPresented: $showingDetail) {
            SyncDetailView(
                syncStatus: syncStatus,
                lastSyncDate: lastSyncDate,
                syncError: syncError
            )
        }
        .onAppear {
            startMonitoringSync()
        }
    }
    
    private func startMonitoringSync() {
        // Monitor CloudKit sync notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("NSPersistentStoreRemoteChangeNotification"),
            object: nil,
            queue: .main
        ) { _ in
            self.syncStatus = .syncing
            
            // Simulate sync completion after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.syncStatus = .synced
                self.lastSyncDate = Date()
            }
        }
        
        // Check initial status
        checkSyncStatus()
    }
    
    private func checkSyncStatus() {
        // Check if running in simulator
        #if targetEnvironment(simulator)
            // In simulator, show as synced to avoid confusion
            syncStatus = .synced
            lastSyncDate = Date()
            syncError = "Running in Simulator - sync simulated"
        #else
            // Check if iCloud is available
            if FileManager.default.ubiquityIdentityToken != nil {
                syncStatus = .synced
                lastSyncDate = Date()
            } else {
                syncStatus = .offline
                // Prompt user to sign in to iCloud
                promptForICloudSignIn()
            }
        #endif
    }
    
    private func promptForICloudSignIn() {
        // Don't automatically prompt - let users discover this themselves
        // This matches the seamless experience of filmz v1
    }
}

struct SyncDetailView: View {
    let syncStatus: SyncStatusView.SyncStatus
    let lastSyncDate: Date?
    let syncError: String?
    @Environment(\.dismiss) var dismiss
    
    private func openICloudSettings() {
        #if os(iOS)
        if let url = URL(string: "App-prefs:CASTLE") {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.internetaccounts") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Sync Status") {
                    HStack {
                        Label(syncStatus.description, systemImage: syncStatus.iconName)
                            .foregroundColor(syncStatus.color)
                        Spacer()
                    }
                    
                    if let lastSync = lastSyncDate {
                        HStack {
                            Text("Last synced")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let error = syncError {
                    Section("Error Details") {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section("Information") {
                    Text("Your film collection automatically syncs across all your devices signed in with the same iCloud account.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Film metadata is cached locally on each device to improve performance and enable offline access.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        Text("iCloud Account")
                        Spacer()
                        #if targetEnvironment(simulator)
                        Text("Simulator")
                            .foregroundColor(.orange)
                        #else
                        if FileManager.default.ubiquityIdentityToken != nil {
                            Text("Signed In")
                                .foregroundColor(.green)
                        } else {
                            Text("Not Signed In")
                                .foregroundColor(.red)
                        }
                        #endif
                    }
                    
                    #if !targetEnvironment(simulator)
                    if FileManager.default.ubiquityIdentityToken == nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sign in to iCloud to sync your film collection across all your devices.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: openICloudSettings) {
                                Label("Open iCloud Settings", systemImage: "gear")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 8)
                    }
                    #else
                    Text("Sync is simulated in the iOS Simulator")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                    #endif
                }
            }
            .navigationTitle("Sync Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SyncStatusView()
}