import SwiftUI

/// A collection of genre pills arranged in a flexible layout
/// Automatically wraps to multiple lines and handles empty states
struct GenrePills: View {
    let genres: [String]
    let style: GenrePillStyle
    let maxDisplayCount: Int?
    let spacing: CGFloat
    
    @State private var showAll = false
    
    init(
        _ genres: [String],
        style: GenrePillStyle = .default,
        maxDisplayCount: Int? = nil,
        spacing: CGFloat = 8
    ) {
        self.genres = genres.filter { !$0.isEmpty }
        self.style = style
        self.maxDisplayCount = maxDisplayCount
        self.spacing = spacing
    }
    
    var body: some View {
        if genres.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: spacing) {
                FlexibleLayout(spacing: spacing) {
                    ForEach(displayedGenres, id: \.self) { genre in
                        GenrePill(genre, style: style)
                    }
                    
                    if shouldShowMoreButton {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAll.toggle()
                            }
                        }) {
                            Text(showAll ? "Less" : "+\(hiddenCount)")
                                .font(style.font)
                                .fontWeight(style.fontWeight)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, style.horizontalPadding)
                                .padding(.vertical, style.verticalPadding)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
    
    private var displayedGenres: [String] {
        guard let maxCount = maxDisplayCount, !showAll else {
            return genres
        }
        return Array(genres.prefix(maxCount))
    }
    
    private var shouldShowMoreButton: Bool {
        guard let maxCount = maxDisplayCount else { return false }
        return genres.count > maxCount
    }
    
    private var hiddenCount: Int {
        guard let maxCount = maxDisplayCount else { return 0 }
        return max(0, genres.count - maxCount)
    }
}


// MARK: - Preview

#Preview("Genre Pills Collection") {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Group {
                Text("All Genres")
                    .font(.headline)
                GenrePills(["Action", "Adventure", "Comedy", "Drama", "Horror", "Romance", "Sci-Fi", "Thriller"])
                
                Text("Limited to 3 with More Button")
                    .font(.headline)
                GenrePills(
                    ["Action", "Adventure", "Comedy", "Drama", "Horror", "Romance"],
                    maxDisplayCount: 3
                )
                
                Text("Compact Style")
                    .font(.headline)
                GenrePills(
                    ["Action", "Adventure", "Comedy", "Drama"],
                    style: .compact
                )
                
                Text("Outlined Style")
                    .font(.headline)
                GenrePills(
                    ["Action", "Adventure", "Comedy"],
                    style: .outlined
                )
                
                Text("Empty State")
                    .font(.headline)
                GenrePills([])
                
                Text("Single Genre")
                    .font(.headline)
                GenrePills(["Action"])
            }
        }
        .padding()
    }
}