import SwiftUI

/// A single rating pill component for displaying film ratings
/// Supports different rating sources with custom icons and colors
struct RatingPill: View {
    let rating: RatingDisplayInfo
    let style: RatingPillStyle
    
    init(_ rating: RatingDisplayInfo, style: RatingPillStyle = .default) {
        self.rating = rating
        self.style = style
    }
    
    var body: some View {
        HStack(spacing: style.iconSpacing) {
            Image(systemName: rating.icon)
                .font(style.iconFont)
                .foregroundColor(rating.color)
            
            Text(rating.value)
                .font(style.textFont)
                .fontWeight(style.fontWeight)
                .foregroundColor(style.textColor)
        }
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .background(style.backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(style.borderColor, lineWidth: style.borderWidth)
        )
    }
}

/// Style configuration for RatingPill
struct RatingPillStyle {
    let textFont: Font
    let iconFont: Font
    let fontWeight: Font.Weight
    let textColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let iconSpacing: CGFloat
    
    static let `default` = RatingPillStyle(
        textFont: .subheadline,
        iconFont: .subheadline,
        fontWeight: .medium,
        textColor: .primary,
        backgroundColor: Color.gray.opacity(0.1),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: 12,
        verticalPadding: 6,
        iconSpacing: 4
    )
    
    static let compact = RatingPillStyle(
        textFont: .caption,
        iconFont: .caption,
        fontWeight: .medium,
        textColor: .primary,
        backgroundColor: Color.gray.opacity(0.1),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: 8,
        verticalPadding: 4,
        iconSpacing: 3
    )
    
    static let outlined = RatingPillStyle(
        textFont: .subheadline,
        iconFont: .subheadline,
        fontWeight: .medium,
        textColor: .primary,
        backgroundColor: Color.clear,
        borderColor: Color.gray.opacity(0.3),
        borderWidth: 1,
        horizontalPadding: 12,
        verticalPadding: 6,
        iconSpacing: 4
    )
    
    static let prominent = RatingPillStyle(
        textFont: .headline,
        iconFont: .headline,
        fontWeight: .semibold,
        textColor: .primary,
        backgroundColor: Color.gray.opacity(0.15),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: 16,
        verticalPadding: 8,
        iconSpacing: 6
    )
}

// MARK: - Preview

#Preview("Rating Pills") {
    VStack(spacing: 16) {
        Group {
            Text("Default Style")
                .font(.headline)
            
            HStack {
                RatingPill(RatingDisplayInfo(
                    source: "IMDB",
                    value: "8.5/10",
                    icon: "star.fill",
                    color: .yellow
                ))
                
                RatingPill(RatingDisplayInfo(
                    source: "Rotten Tomatoes",
                    value: "85%",
                    icon: "tomato.fill",
                    color: .red
                ))
            }
            
            Text("Compact Style")
                .font(.headline)
            
            HStack {
                RatingPill(
                    RatingDisplayInfo(
                        source: "IMDB",
                        value: "8.5/10",
                        icon: "star.fill",
                        color: .yellow
                    ),
                    style: .compact
                )
                
                RatingPill(
                    RatingDisplayInfo(
                        source: "Metacritic",
                        value: "75/100",
                        icon: "m.square.fill",
                        color: .blue
                    ),
                    style: .compact
                )
            }
            
            Text("Outlined Style")
                .font(.headline)
            
            RatingPill(
                RatingDisplayInfo(
                    source: "IMDB",
                    value: "9.0/10",
                    icon: "star.fill",
                    color: .yellow
                ),
                style: .outlined
            )
            
            Text("Prominent Style")
                .font(.headline)
            
            RatingPill(
                RatingDisplayInfo(
                    source: "IMDB",
                    value: "9.0/10",
                    icon: "star.fill",
                    color: .yellow
                ),
                style: .prominent
            )
        }
    }
    .padding()
}