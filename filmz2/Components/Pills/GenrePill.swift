import SwiftUI

/// A single genre pill component for displaying film genres
/// Reusable component that adapts to content and supports theming
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
        font: .subheadline,
        fontWeight: .medium,
        foregroundColor: .blue,
        backgroundColor: Color.blue.opacity(0.1),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: 12,
        verticalPadding: 6
    )
    
    static let outlined = GenrePillStyle(
        font: .subheadline,
        fontWeight: .medium,
        foregroundColor: .blue,
        backgroundColor: Color.clear,
        borderColor: .blue,
        borderWidth: 1,
        horizontalPadding: 12,
        verticalPadding: 6
    )
    
    static let compact = GenrePillStyle(
        font: .caption,
        fontWeight: .medium,
        foregroundColor: .blue,
        backgroundColor: Color.blue.opacity(0.1),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: 8,
        verticalPadding: 4
    )
    
    static let neutral = GenrePillStyle(
        font: .subheadline,
        fontWeight: .medium,
        foregroundColor: .primary,
        backgroundColor: Color.gray.opacity(0.2),
        borderColor: Color.clear,
        borderWidth: 0,
        horizontalPadding: 12,
        verticalPadding: 6
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