import SwiftUI

/// A collection of rating pills for displaying multiple film ratings
/// Automatically arranges ratings in a flexible layout
struct RatingPills: View {
    let ratings: [RatingDisplayInfo]
    let style: RatingPillStyle
    let layout: RatingPillsLayout
    let spacing: CGFloat
    
    init(
        _ ratings: [RatingDisplayInfo],
        style: RatingPillStyle = .default,
        layout: RatingPillsLayout = .horizontal,
        spacing: CGFloat = 8
    ) {
        self.ratings = ratings
        self.style = style
        self.layout = layout
        self.spacing = spacing
    }
    
    var body: some View {
        if ratings.isEmpty {
            EmptyView()
        } else {
            Group {
                switch layout {
                case .horizontal:
                    horizontalLayout
                case .vertical:
                    verticalLayout
                case .flexible:
                    flexibleLayout
                }
            }
        }
    }
    
    private var horizontalLayout: some View {
        HStack(spacing: spacing) {
            ForEach(ratings, id: \.source) { rating in
                RatingPill(rating, style: style)
            }
            Spacer()
        }
    }
    
    private var verticalLayout: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(ratings, id: \.source) { rating in
                RatingPill(rating, style: style)
            }
        }
    }
    
    private var flexibleLayout: some View {
        FlexibleLayout(spacing: spacing) {
            ForEach(ratings, id: \.source) { rating in
                RatingPill(rating, style: style)
            }
        }
    }
}

/// Layout options for RatingPills
enum RatingPillsLayout {
    case horizontal  // Pills arranged in a horizontal line
    case vertical    // Pills stacked vertically
    case flexible    // Pills wrap to multiple lines as needed
}

// MARK: - Preview

#Preview("Rating Pills Collection") {
    let sampleRatings = [
        RatingDisplayInfo(source: "IMDB", value: "8.5/10", icon: "star.fill", color: .yellow),
        RatingDisplayInfo(source: "Rotten Tomatoes", value: "85%", icon: "tomato.fill", color: .red),
        RatingDisplayInfo(source: "Metacritic", value: "75/100", icon: "m.square.fill", color: .blue)
    ]
    
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Group {
                Text("Horizontal Layout")
                    .font(.headline)
                RatingPills(sampleRatings, layout: .horizontal)
                
                Text("Vertical Layout")
                    .font(.headline)
                RatingPills(sampleRatings, layout: .vertical)
                
                Text("Flexible Layout")
                    .font(.headline)
                RatingPills(sampleRatings, layout: .flexible)
                
                Text("Compact Style")
                    .font(.headline)
                RatingPills(sampleRatings, style: .compact, layout: .horizontal)
                
                Text("Outlined Style")
                    .font(.headline)
                RatingPills(sampleRatings, style: .outlined, layout: .flexible)
                
                Text("Prominent Style")
                    .font(.headline)
                RatingPills([sampleRatings[0]], style: .prominent)
                
                Text("Empty State")
                    .font(.headline)
                RatingPills([])
                
                Text("Single Rating")
                    .font(.headline)
                RatingPills([sampleRatings[0]])
            }
        }
        .padding()
    }
}