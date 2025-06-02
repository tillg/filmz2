//
//  CachedIMDBFilm.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import Foundation
import SwiftData

/// Cached film data from OMDB API to reduce API calls and enable offline access
@Model
final class CachedIMDBFilm {
    // Identity
    @Attribute(.unique) var imdbID: String
    
    // Core film data
    var title: String
    var year: String?
    var rated: String?
    var released: String?
    var runtime: String?
    var genre: String?
    var director: String?
    var writer: String?
    var actors: String?
    var plot: String?
    var language: String?
    var country: String?
    var awards: String?
    var poster: String?
    var metascore: String?
    var imdbRating: String?
    var imdbVotes: String?
    var type: String?
    
    // Cache metadata
    var lastFetched: Date
    var dataVersion: Int
    
    init(from imdbFilm: IMDBFilm) {
        self.imdbID = imdbFilm.imdbID
        self.title = imdbFilm.title
        self.year = imdbFilm.year
        self.rated = imdbFilm.rated
        self.released = imdbFilm.released
        self.runtime = imdbFilm.runtime
        self.genre = imdbFilm.genre
        self.director = imdbFilm.director
        self.writer = imdbFilm.writer
        self.actors = imdbFilm.actors
        self.plot = imdbFilm.plot
        self.language = imdbFilm.language
        self.country = imdbFilm.country
        self.awards = imdbFilm.awards
        self.poster = imdbFilm.poster
        self.metascore = imdbFilm.metascore
        self.imdbRating = imdbFilm.imdbRating
        self.imdbVotes = imdbFilm.imdbVotes
        self.type = imdbFilm.type
        
        self.lastFetched = Date()
        self.dataVersion = 1
    }
    
    /// Convert back to IMDBFilm for API compatibility
    func toIMDBFilm() -> IMDBFilm {
        IMDBFilm(
            title: title,
            imdbID: imdbID,
            year: year,
            rated: rated,
            released: released,
            runtime: runtime,
            genre: genre,
            director: director,
            writer: writer,
            actors: actors,
            plot: plot,
            language: language,
            country: country,
            awards: awards,
            poster: poster,
            ratings: nil,  // We don't cache ratings array for simplicity
            metascore: metascore,
            imdbRating: imdbRating,
            imdbVotes: imdbVotes,
            type: type,
            response: "True"
        )
    }
    
    /// Check if cache is stale (older than 30 days)
    var isStale: Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return lastFetched < thirtyDaysAgo
    }
}