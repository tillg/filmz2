//
//  MyRatingView.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI

/// Displays user's personal rating with red heart icon
struct MyRatingView: View {
    let rating: Int?
    
    var body: some View {
        if let rating = rating {
            HStack(spacing: 4) {
                Text("❤️")
                    .font(.system(size: 14))
                
                Text("\(rating)/10")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("My rating: \(rating) out of 10")
        }
    }
}

// MARK: - Previews

#Preview("My Ratings") {
    VStack(alignment: .leading, spacing: 16) {
        Group {
            MyRatingView(rating: 10)
            MyRatingView(rating: 8)
            MyRatingView(rating: 5)
            MyRatingView(rating: 1)
            MyRatingView(rating: nil)
        }
        .padding(.horizontal)
    }
    .padding()
}