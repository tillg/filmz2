//
//  StarRatingView.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//  Updated to follow Apple Human Interface Guidelines
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int?
    let maxRating = 10
    let starStyle: StarStyle
    
    init(rating: Binding<Int?>, style: StarStyle = .medium) {
        self._rating = rating
        self.starStyle = style
    }
    
    enum StarStyle {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return DesignTokens.Typography.footnote
            case .medium: return DesignTokens.Typography.title3
            case .large: return DesignTokens.Typography.title2
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 4
            case .large: return 6
            }
        }
    }
    
    var body: some View {
        HStack(spacing: starStyle.spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    if rating == index {
                        // Tapping the same rating clears it
                        rating = nil
                    } else {
                        rating = index
                    }
                }) {
                    Image(systemName: starImage(for: index))
                        .font(starStyle.font)
                        .foregroundColor(starColor(for: index))
                }
                .buttonStyle(.plain)
                .appleTapTarget(minSize: DesignTokens.Accessibility.minimumTapTarget)
                .accessibilityLabel("\(index) stars")
                .accessibilityHint(rating == index ? "Tap to clear rating" : "Tap to rate \(index) stars")
            }
            
            if let rating = rating {
                Text("\(rating)/\(maxRating)")
                    .font(DesignTokens.Typography.subheadline)
                    .foregroundColor(DesignTokens.Colors.secondary)
                    .padding(.leading, DesignTokens.Spacing.extraSmall.rawValue)
            }
        }
    }
    
    private func starImage(for index: Int) -> String {
        guard let rating = rating else {
            return "star"
        }
        return index <= rating ? "star.fill" : "star"
    }
    
    private func starColor(for index: Int) -> Color {
        guard let rating = rating else {
            return DesignTokens.Colors.quaternaryFill
        }
        return index <= rating ? Color.yellow : DesignTokens.Colors.quaternaryFill
    }
}

#Preview("No Rating") {
    @Previewable @State var rating: Int? = nil
    return StarRatingView(rating: $rating)
        .padding()
}

#Preview("With Rating") {
    @Previewable @State var rating: Int? = 7
    return StarRatingView(rating: $rating)
        .padding()
}

#Preview("Small Stars") {
    @Previewable @State var rating: Int? = 5
    return StarRatingView(rating: $rating, style: .small)
        .padding()
}