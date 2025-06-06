import SwiftUI

/// A single genre pill component for displaying film genres
/// Reusable component that adapts to content and supports theming
/// Updated to follow Apple Human Interface Guidelines
struct GenrePill: View {
    let genre: String
    let style: GenrePillStyle
    
    init(_ genre: String, style: GenrePillStyle = .default) {
        self.genre = genre
        self.style = style
    }
    
    var body: some View {
        Text(genre)
            .font(style.font)
            .fontWeight(style.fontWeight)
            .foregroundColor(style.foregroundColor)
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

/// Style configuration for GenrePill
struct GenrePillStyle {
    let font: Font
    let fontWeight: Font.Weight
    let foregroundColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    
    static let `default` = GenrePillStyle(
        font: DesignTokens.Typography.subheadline,
        fontWeight: .medium,
        foregroundColor: DesignTokens.Colors.accent,
        backgroundColor: DesignTokens.Colors.accent.opacity(0.15),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: DesignTokens.Spacing.small.rawValue,
        verticalPadding: DesignTokens.Spacing.extraSmall.rawValue
    )
    
    static let outlined = GenrePillStyle(
        font: DesignTokens.Typography.subheadline,
        fontWeight: .medium,
        foregroundColor: DesignTokens.Colors.accent,
        backgroundColor: Color.clear,
        borderColor: DesignTokens.Colors.accent,
        borderWidth: 1,
        horizontalPadding: DesignTokens.Spacing.small.rawValue,
        verticalPadding: DesignTokens.Spacing.extraSmall.rawValue
    )
    
    static let compact = GenrePillStyle(
        font: DesignTokens.Typography.caption,
        fontWeight: .medium,
        foregroundColor: DesignTokens.Colors.accent,
        backgroundColor: DesignTokens.Colors.accent.opacity(0.15),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: DesignTokens.Spacing.extraSmall.rawValue,
        verticalPadding: 4
    )
    
    static let neutral = GenrePillStyle(
        font: DesignTokens.Typography.subheadline,
        fontWeight: .medium,
        foregroundColor: DesignTokens.Colors.primary,
        backgroundColor: DesignTokens.Colors.secondaryFill,
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: DesignTokens.Spacing.small.rawValue,
        verticalPadding: DesignTokens.Spacing.extraSmall.rawValue
    )
}

// MARK: - Preview

#Preview("Genre Pills") {
    VStack(spacing: 16) {
        Group {
            Text("Default Style")
                .font(.headline)
            GenrePill("Action")
            
            Text("Outlined Style")
                .font(.headline)
            GenrePill("Drama", style: .outlined)
            
            Text("Compact Style")
                .font(.headline)
            GenrePill("Comedy", style: .compact)
            
            Text("Neutral Style")
                .font(.headline)
            GenrePill("Thriller", style: .neutral)
        }
    }
    .padding()
}