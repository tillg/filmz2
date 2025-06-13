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
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starImage(for: index))
                    .font(.system(size: starSize))
                    .foregroundColor(starColor(for: index))
                    .frame(minWidth: 0)
                    .onTapGesture {
                        if rating == index {
                            // Tapping the same rating clears it
                            rating = nil
                        } else {
                            rating = index
                        }
                    }
            }
            
            // Always reserve space for rating text to maintain consistent layout
            Group {
                if let rating = rating {
                    Text("\(rating)/\(maxRating)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                } else {
                    Text(" ")
                        .font(.subheadline)
                        .opacity(0)
                }
            }
            .padding(.leading, 4)
            .frame(minWidth: 20, alignment: .leading)
        }
        .clipped()
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

#Preview("Tight Container - No Rating") {
    @Previewable @State var rating: Int? = nil
    return StarRatingView(rating: $rating, starSize: 20)
        .padding(8)
        .frame(width: 200, height: 40)
        .border(Color.red, width: 2)
        .padding()
}

#Preview("Tight Container - With Rating") {
    @Previewable @State var rating: Int? = 8
    return StarRatingView(rating: $rating, starSize: 20)
        .padding(8)
        .frame(width: 200, height: 40)
        .border(Color.blue, width: 2)
        .padding()
}

#Preview("Very Tight Container") {
    @Previewable @State var rating: Int? = 10
    return StarRatingView(rating: $rating, starSize: 18)
        .padding(4)
        .frame(width: 180, height: 35)
        .border(Color.green, width: 2)
        .padding()
}
