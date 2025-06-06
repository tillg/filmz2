import SwiftUI

/// A single rating pill component for displaying film ratings
/// Supports different rating sources with custom icons and colors
/// Updated to follow Apple Human Interface Guidelines
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
        textFont: DesignTokens.Typography.subheadline,
        iconFont: DesignTokens.Typography.subheadline,
        fontWeight: .medium,
        textColor: DesignTokens.Colors.primary,
        backgroundColor: DesignTokens.Colors.secondaryFill,
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: DesignTokens.Spacing.small.rawValue,
        verticalPadding: DesignTokens.Spacing.extraSmall.rawValue,
        iconSpacing: 4
    )
    
    static let compact = RatingPillStyle(
        textFont: DesignTokens.Typography.caption,
        iconFont: DesignTokens.Typography.caption,
        fontWeight: .medium,
        textColor: DesignTokens.Colors.primary,
        backgroundColor: DesignTokens.Colors.secondaryFill,
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: DesignTokens.Spacing.extraSmall.rawValue,
        verticalPadding: 4,
        iconSpacing: 3
    )
    
    static let outlined = RatingPillStyle(
        textFont: DesignTokens.Typography.subheadline,
        iconFont: DesignTokens.Typography.subheadline,
        fontWeight: .medium,
        textColor: DesignTokens.Colors.primary,
        backgroundColor: Color.clear,
        borderColor: DesignTokens.Colors.quaternaryFill,
        borderWidth: 1,
        horizontalPadding: DesignTokens.Spacing.small.rawValue,
        verticalPadding: DesignTokens.Spacing.extraSmall.rawValue,
        iconSpacing: 4
    )
    
    static let prominent = RatingPillStyle(
        textFont: DesignTokens.Typography.headline,
        iconFont: DesignTokens.Typography.headline,
        fontWeight: .semibold,
        textColor: DesignTokens.Colors.primary,
        backgroundColor: DesignTokens.Colors.tertiaryFill,
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: DesignTokens.Spacing.small.rawValue,
        verticalPadding: DesignTokens.Spacing.extraSmall.rawValue,
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