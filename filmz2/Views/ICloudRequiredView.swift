//
//  ICloudRequiredView.swift
//  filmz2
//
//  Created by Till Gartner on 03.06.25.
//

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct ICloudRequiredView: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "icloud.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("iCloud Required")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Please sign in to iCloud to use Filmz")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: openICloudSettings) {
                Label("Open Settings", systemImage: "gear")
                    .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Spacer()
        }
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