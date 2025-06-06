import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(DesignTokens.Colors.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2025.06.02")
                        .foregroundColor(DesignTokens.Colors.secondary)
                }
            }
            
            Section("Credits") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Developed by Till Gartner")
                        .font(DesignTokens.Typography.headline)
                    Text("Powered by OMDb API")
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.secondary)
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