//
//  FilmMetadataSection.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import SwiftUI

struct FilmMetadataSection: View {
    let genres: [String]
    let director: String?
    let actors: String?
    let writers: String?
    let released: String?
    let runtime: String?
    let language: String?
    let country: String?
    let awards: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Genres
            if !genres.isEmpty {
                GenrePills(genres)
            }
            
            // Director
            if let director = director, !director.isEmpty {
                FilmInfoRow(title: "Director", content: director)
            }
            
            // Release Info
            if let released = released, !released.isEmpty {
                FilmInfoRow(title: "Released", content: released)
            }
            
            // Origin
            if let language = language, let country = country {
                FilmInfoRow(title: "Origin", content: "\(language) • \(country)")
            } else if let country = country {
                FilmInfoRow(title: "Origin", content: country)
            } else if let language = language {
                FilmInfoRow(title: "Language", content: language)
            }
            
            // Awards
            if let awards = awards, !awards.isEmpty {
                FilmInfoRow(title: "Awards", content: awards)
            }
        }
    }
}

#Preview {
    FilmMetadataSection(
        genres: ["Action", "Crime", "Drama"],
        director: "Christopher Nolan",
        actors: "Christian Bale, Heath Ledger, Aaron Eckhart",
        writers: "Jonathan Nolan, Christopher Nolan",
        released: "18 Jul 2008",
        runtime: "152 min",
        language: "English, Mandarin",
        country: "United States, United Kingdom",
        awards: "Won 2 Oscars. 164 wins & 164 nominations total"
    )
    .padding()
}