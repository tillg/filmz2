import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2025.06.02")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Credits") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Developed by Till Gartner")
                        .font(.headline)
                    Text("Powered by OMDb API")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}