//
//  DesignTokens.swift
//  filmz2
//
//  Created by Claude on 06.06.25.
//

import SwiftUI

/// Design tokens following Apple Human Interface Guidelines
/// Provides consistent spacing, colors, and typography throughout the app
extension View {
    
    // MARK: - Spacing
    /// Standard spacing values following Apple HIG (8, 16, 20, 24 pts)
    
    func padding(_ edges: Edge.Set = .all, _ length: DesignTokens.Spacing) -> some View {
        self.padding(edges, length.rawValue)
    }
}

struct DesignTokens {
    
    // MARK: - Spacing
    enum Spacing: CGFloat, CaseIterable {
        case extraSmall = 8
        case small = 16
        case medium = 20
        case large = 24
        case extraLarge = 32
        
        var rawValue: CGFloat {
            switch self {
            case .extraSmall: return 8
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            case .extraLarge: return 32
            }
        }
    }
    
    // MARK: - Typography
    /// Semantic font styles following Apple's type system
    struct Typography {
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Colors
    /// Semantic colors following Apple HIG
    struct Colors {
        // Primary colors
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let accent = Color.accentColor
        
        // Background colors
        #if os(iOS)
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        
        // Fill colors
        static let fill = Color(UIColor.systemFill)
        static let secondaryFill = Color(UIColor.secondarySystemFill)
        static let tertiaryFill = Color(UIColor.tertiarySystemFill)
        static let quaternaryFill = Color(UIColor.quaternarySystemFill)
        #else
        static let background = Color(.windowBackground)
        static let secondaryBackground = Color(.controlBackgroundColor)
        static let tertiaryBackground = Color(.controlColor)
        
        // Fill colors
        static let fill = Color(.controlColor)
        static let secondaryFill = Color(.controlBackgroundColor)
        static let tertiaryFill = Color(.separatorColor)
        static let quaternaryFill = Color(.quaternaryLabelColor)
        #endif
        
        // Status colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Rating colors (semantic)
        static let ratingGood = Color.green
        static let ratingMedium = Color.orange
        static let ratingPoor = Color.red
        static let ratingUnknown = Color.secondary
    }
    
    // MARK: - Button Styles
    struct ButtonStyles {
        static let primary = BorderedProminentButtonStyle()
        static let secondary = BorderedButtonStyle()
        static let plain = PlainButtonStyle()
        static let destructive = BorderedButtonStyle()
    }
    
    // MARK: - Corner Radius
    enum CornerRadius: CGFloat {
        case small = 8
        case medium = 12
        case large = 16
        case extraLarge = 20
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let minimumTapTarget: CGFloat = 44
        static let preferredTapTarget: CGFloat = 48
    }
}

// MARK: - Button Style Extensions
// Note: These extensions are for convenience but may have platform limitations

// MARK: - Convenient Modifiers
extension View {
    func appleTapTarget(minSize: CGFloat = DesignTokens.Accessibility.minimumTapTarget) -> some View {
        self.frame(minWidth: minSize, minHeight: minSize)
    }
    
    func appleCornerRadius(_ radius: DesignTokens.CornerRadius = .medium) -> some View {
        self.cornerRadius(radius.rawValue)
    }
    
    func appleCardStyle() -> some View {
        self
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.medium.rawValue))
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}