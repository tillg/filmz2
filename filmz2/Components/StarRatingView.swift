//
//  StarRatingView.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int?
    let maxRating = 10
    let starSize: CGFloat
    
    init(rating: Binding<Int?>, starSize: CGFloat = 24) {
        self._rating = rating
        self.starSize = starSize
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starImage(for: index))
                    .font(.system(size: starSize))
                    .foregroundColor(starColor(for: index))
                    .onTapGesture {
                        if rating == index {
                            // Tapping the same rating clears it
                            rating = nil
                        } else {
                            rating = index
                        }
                    }
            }
            
            if let rating = rating {
                Text("\(rating)/\(maxRating)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
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
            return .gray
        }
        return index <= rating ? .yellow : .gray
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
    return StarRatingView(rating: $rating, starSize: 16)
        .padding()
}