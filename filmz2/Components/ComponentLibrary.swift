import SwiftUI

/// Central documentation and showcase for all reusable UI components
/// This file serves as a living style guide and component catalog
struct ComponentLibrary: View {
    @State private var selectedCategory: ComponentCategory = .pills
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Selector
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ComponentCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Component Showcase
                ScrollView {
                    selectedCategory.contentView
                        .padding()
                }
            }
            .navigationTitle("Component Library")
        }
    }
}

/// Categories of UI components
enum ComponentCategory: CaseIterable {
    case pills
    case buttons
    case cards
    case inputs
    
    var displayName: String {
        switch self {
        case .pills: return "Pills"
        case .buttons: return "Buttons"
        case .cards: return "Cards"
        case .inputs: return "Inputs"
        }
    }
    
    @ViewBuilder
    var contentView: some View {
        switch self {
        case .pills:
            PillsShowcase()
        case .buttons:
            Text("Buttons - Coming Soon")
                .foregroundColor(.secondary)
        case .cards:
            Text("Cards - Coming Soon")
                .foregroundColor(.secondary)
        case .inputs:
            Text("Inputs - Coming Soon")
                .foregroundColor(.secondary)
        }
    }
}

/// Showcase for pill components
private struct PillsShowcase: View {
    let sampleGenres = ["Action", "Adventure", "Comedy", "Drama", "Horror", "Romance", "Sci-Fi", "Thriller"]
    let sampleRatings = [
        RatingDisplayInfo(source: "IMDB", value: "8.5/10", icon: "star.fill", color: .yellow),
        RatingDisplayInfo(source: "Rotten Tomatoes", value: "85%", icon: "tomato.fill", color: .red),
        RatingDisplayInfo(source: "Metacritic", value: "75/100", icon: "m.square.fill", color: .blue)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Genre Pills Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Genre Pills")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Group {
                    ComponentDemo(title: "Default Style") {
                        GenrePills(Array(sampleGenres.prefix(4)))
                    }
                    
                    ComponentDemo(title: "Compact Style") {
                        GenrePills(Array(sampleGenres.prefix(3)), style: .compact)
                    }
                    
                    ComponentDemo(title: "Outlined Style") {
                        GenrePills(Array(sampleGenres.prefix(3)), style: .outlined)
                    }
                    
                    ComponentDemo(title: "With Show More (max 3)") {
                        GenrePills(sampleGenres, maxDisplayCount: 3)
                    }
                    
                    ComponentDemo(title: "Single Pill") {
                        GenrePill("Action")
                    }
                }
            }
            
            Divider()
            
            // Rating Pills Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Rating Pills")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Group {
                    ComponentDemo(title: "Horizontal Layout") {
                        RatingPills(sampleRatings, layout: .horizontal)
                    }
                    
                    ComponentDemo(title: "Vertical Layout") {
                        RatingPills(sampleRatings, layout: .vertical)
                    }
                    
                    ComponentDemo(title: "Flexible Layout") {
                        RatingPills(sampleRatings, layout: .flexible)
                    }
                    
                    ComponentDemo(title: "Compact Style") {
                        RatingPills(sampleRatings, style: .compact, layout: .horizontal)
                    }
                    
                    ComponentDemo(title: "Prominent Style") {
                        RatingPills([sampleRatings[0]], style: .prominent)
                    }
                    
                    ComponentDemo(title: "Single Rating") {
                        RatingPill(sampleRatings[0])
                    }
                }
            }
        }
    }
}

/// Wrapper for demonstrating individual components
private struct ComponentDemo<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            content
                .padding()
                .background(Color.gray.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - Preview

#Preview("Component Library") {
    ComponentLibrary()
}

#Preview("Pills Only") {
    NavigationView {
        ScrollView {
            PillsShowcase()
                .padding()
        }
        .navigationTitle("Pills")
    }
}