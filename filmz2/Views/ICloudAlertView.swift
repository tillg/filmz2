//
//  ICloudAlertView.swift
//  filmz2
//
//  Created by Till Gartner on 03.06.25.
//

import SwiftUI

struct ICloudAlertModifier: ViewModifier {
    @AppStorage("HasShownICloudAlert") private var hasShownAlert = false
    @State private var showingAlert = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                checkICloudStatus()
            }
            .alert("Enable iCloud Sync", isPresented: $showingAlert) {
                Button("Open Settings") {
                    openICloudSettings()
                }
                Button("Not Now", role: .cancel) {
                    // User chose not to enable iCloud
                }
            } message: {
                Text("Sign in to iCloud to automatically sync your film collection across all your devices. You can always enable this later in Settings.")
            }
    }
    
    private func checkICloudStatus() {
        #if !targetEnvironment(simulator)
        // Only show once and only if not signed in
        if !hasShownAlert && FileManager.default.ubiquityIdentityToken == nil {
            hasShownAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingAlert = true
            }
        }
        #endif
    }
    
    private func openICloudSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.internetaccounts") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}

extension View {
    func iCloudSyncAlert() -> some View {
        modifier(ICloudAlertModifier())
    }
}