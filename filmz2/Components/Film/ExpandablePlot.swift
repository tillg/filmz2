//
//  ExpandablePlot.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import SwiftUI

struct ExpandablePlot: View {
    let plot: String
    let maxLength: Int
    @State private var isExpanded = false
    
    init(plot: String, maxLength: Int = 150) {
        self.plot = plot
        self.maxLength = maxLength
    }
    
    private var shouldTruncate: Bool {
        plot.count > maxLength
    }
    
    private var truncatedPlot: String {
        guard shouldTruncate && !isExpanded else { return plot }
        let endIndex = plot.index(plot.startIndex, offsetBy: maxLength)
        return String(plot[..<endIndex]) + "..."
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plot")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(isExpanded ? plot : truncatedPlot)
                    .font(.body)
                    .lineSpacing(4)
                
                if shouldTruncate {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Show Less" : "Read More")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

#Preview("Short Plot") {
    ExpandablePlot(plot: "A computer hacker learns about the true nature of reality.")
        .padding()
}

#Preview("Long Plot") {
    ExpandablePlot(plot: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice. The Dark Knight raises the stakes in every way.")
        .padding()
}