//
//  FilmCastAndCrewSection.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import SwiftUI

struct FilmCastAndCrewSection: View {
    let actors: String?
    let writers: String?
    
    var body: some View {
        if actors != nil || writers != nil {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cast & Crew")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let actors = actors, !actors.isEmpty {
                    FilmInfoRow(title: "Starring", content: actors)
                }
                
                if let writers = writers, !writers.isEmpty {
                    FilmInfoRow(title: "Writers", content: writers)
                }
            }
        }
    }
}

#Preview {
    FilmCastAndCrewSection(
        actors: "Christian Bale, Heath Ledger, Aaron Eckhart",
        writers: "Jonathan Nolan, Christopher Nolan"
    )
    .padding()
}