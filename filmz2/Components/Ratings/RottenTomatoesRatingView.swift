//
//  RottenTomatoesRatingView.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI

/// Displays Rotten Tomatoes rating with tomato icon
struct RottenTomatoesRatingView: View {
    let rating: String?
    
    var body: some View {
        if let rating = rating, rating != "N/A", !rating.isEmpty {
            HStack(spacing: 4) {
                Text("🍅")
                    .font(.system(size: 14))
                
                Text(rating)
                    .font(.caption)
                    .foregroundColor(ratingColor(for: rating))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Rotten Tomatoes rating: \(rating)")
        }
    }
    
    private func ratingColor(for rating: String) -> Color {
        // Extract percentage value
        let percentage = rating.replacingOccurrences(of: "%", with: "")
        guard let value = Int(percentage) else { return .primary }
        
        // Fresh (60% or higher) = green/red based on theme
        // Rotten (below 60%) = gray
        if value >= 60 {
            return .green
        } else {
            return .gray
        }
    }
}

// MARK: - Previews

#Preview("Rotten Tomatoes Ratings") {
    VStack(alignment: .leading, spacing: 16) {
        Group {
            RottenTomatoesRatingView(rating: "94%")  // Fresh
            RottenTomatoesRatingView(rating: "85%")  // Fresh
            RottenTomatoesRatingView(rating: "60%")  // Fresh (boundary)
            RottenTomatoesRatingView(rating: "59%")  // Rotten
            RottenTomatoesRatingView(rating: "25%")  // Rotten
            RottenTomatoesRatingView(rating: nil)
            RottenTomatoesRatingView(rating: "N/A")
        }
        .padding(.horizontal)
    }
    .padding()
}