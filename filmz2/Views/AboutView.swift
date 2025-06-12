import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: DesignTokens.Spacing.medium.rawValue) {
                    Image("FilmzLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 80)
                    
                    Text("Filmz")
                        .font(DesignTokens.Typography.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.medium.rawValue)
                .listRowBackground(Color.clear)
            }
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(BuildInfo.version)
                        .foregroundColor(DesignTokens.Colors.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    if BuildInfo.isValidCommitHash {
                        Link(BuildInfo.formattedBuildInfo, destination: URL(string: BuildInfo.githubCommitURL)!)
                            .foregroundColor(.blue)
                    } else {
                        Text(BuildInfo.formattedBuildInfo)
                            .foregroundColor(DesignTokens.Colors.secondary)
                    }
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