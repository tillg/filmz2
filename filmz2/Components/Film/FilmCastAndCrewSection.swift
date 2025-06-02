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
        let hasContent = (actors != nil && !actors!.isEmpty && actors != "N/A") || 
                        (writers != nil && !writers!.isEmpty && writers != "N/A")
        
        if hasContent {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cast & Crew")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                FilmInfoRow(title: "Starring", content: actors)
                FilmInfoRow(title: "Writers", content: writers)
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