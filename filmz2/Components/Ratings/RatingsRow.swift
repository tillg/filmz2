//
//  RatingsRow.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI

/// Displays a horizontal row of all available ratings
struct RatingsRow: View {
    let imdbRating: String?
    let rottenTomatoesRating: String?
    let myRating: Int?
    let layout: Layout
    
    enum Layout {
        case horizontal
        case wrapping
    }
    
    init(imdbRating: String? = nil, 
         rottenTomatoesRating: String? = nil,
         myRating: Int? = nil,
         layout: Layout = .horizontal) {
        self.imdbRating = imdbRating
        self.rottenTomatoesRating = rottenTomatoesRating
        self.myRating = myRating
        self.layout = layout
    }
    
    /// Initialize from an IMDBFilm model
    init(film: IMDBFilm, myRating: Int? = nil, layout: Layout = .horizontal) {
        self.imdbRating = film.imdbRating
        self.rottenTomatoesRating = film.rottenTomatoesRating
        self.myRating = myRating
        self.layout = layout
    }
    
    var body: some View {
        Group {
            if layout == .horizontal {
                HStack(spacing: 16) {
                    ratingsContent
                }
            } else {
                FlowLayout(spacing: 16) {
                    ratingsContent
                }
            }
        }
    }
    
    @ViewBuilder
    private var ratingsContent: some View {
        IMDBRatingView(rating: imdbRating)
        RottenTomatoesRatingView(rating: rottenTomatoesRating)
        MyRatingView(rating: myRating)
    }
    
    /// Returns true if at least one rating is available
    var hasAnyRating: Bool {
        (imdbRating != nil && imdbRating != "N/A" && !imdbRating!.isEmpty) ||
        (rottenTomatoesRating != nil && rottenTomatoesRating != "N/A" && !rottenTomatoesRating!.isEmpty) ||
        myRating != nil
    }
}

// Simple flow layout for wrapping ratings
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width > proposal.width ?? .infinity {
                width = max(width, lineWidth - spacing)
                height += lineHeight + spacing
                lineWidth = size.width + spacing
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        
        width = max(width, lineWidth - spacing)
        height += lineHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Previews

#Preview("Ratings Row - All Ratings") {
    VStack(spacing: 20) {
        Text("Horizontal Layout").font(.headline)
        RatingsRow(
            imdbRating: "8.5",
            rottenTomatoesRating: "94%",
            myRating: 9
        )
        
        Divider()
        
        Text("Wrapping Layout").font(.headline)
        RatingsRow(
            imdbRating: "8.5",
            rottenTomatoesRating: "94%",
            myRating: 9,
            layout: .wrapping
        )
        .frame(width: 200)
        .border(Color.gray.opacity(0.3))
    }
    .padding()
}

#Preview("Ratings Row - Partial Ratings") {
    VStack(alignment: .leading, spacing: 20) {
        Text("IMDB Only")
        RatingsRow(imdbRating: "7.2")
        
        Text("RT Only")
        RatingsRow(rottenTomatoesRating: "85%")
        
        Text("My Rating Only")
        RatingsRow(myRating: 8)
        
        Text("IMDB + My Rating")
        RatingsRow(imdbRating: "6.8", myRating: 7)
        
        Text("No Ratings")
        RatingsRow()
            .background(Color.gray.opacity(0.1))
    }
    .padding()
}

#Preview("Ratings Row - From Film Model") {
    RatingsRow(film: IMDBFilm.darkKnight, myRating: 10)
        .padding()
}