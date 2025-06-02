//
//  IMDBRatingView.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI

/// Displays IMDB rating with yellow star icon
struct IMDBRatingView: View {
    let rating: String?
    
    var body: some View {
        if let rating = rating, rating != "N/A", !rating.isEmpty {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                
                Text(rating.contains("/") ? rating : "\(rating)/10")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("IMDB rating: \(rating)")
        }
    }
}

// MARK: - Previews

#Preview("IMDB Ratings") {
    VStack(alignment: .leading, spacing: 16) {
        Group {
            IMDBRatingView(rating: "8.5")
            IMDBRatingView(rating: "7.2/10")
            IMDBRatingView(rating: "10.0")
            IMDBRatingView(rating: nil)
            IMDBRatingView(rating: "N/A")
            IMDBRatingView(rating: "")
        }
        .padding(.horizontal)
    }
    .padding()
}