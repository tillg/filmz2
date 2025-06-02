//
//  MyFilm.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

import Foundation
import SwiftData

enum AudienceType: String, Codable {
    case meAlone = "Me alone"
    case meAndPartner = "Me and partner"
    case family = "Family"
}

@Model
final class MyFilm {
    // Identity
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var imdbID: String
    
    // User Data
    var myRating: Int?
    var dateAdded: Date
    var watched: Bool
    var dateWatched: Date?
    var audience: AudienceType?
    var recommendedBy: String?
    var notes: String?
    
    // Cached Film Data
    var title: String
    var year: String?
    var posterURL: String?
    var genres: [String]
    var director: String?
    var runtime: String?
    var plot: String?
    
    init(
        imdbID: String,
        title: String,
        year: String? = nil,
        posterURL: String? = nil,
        genres: [String] = [],
        director: String? = nil,
        runtime: String? = nil,
        plot: String? = nil
    ) {
        self.id = UUID()
        self.imdbID = imdbID
        self.title = title
        self.year = year
        self.posterURL = posterURL
        self.genres = genres
        self.director = director
        self.runtime = runtime
        self.plot = plot
        
        // Default values
        self.dateAdded = Date()
        self.watched = false
        self.myRating = nil
        self.dateWatched = nil
        self.audience = nil
        self.recommendedBy = nil
        self.notes = nil
    }
    
    // Convenience initializer from IMDBFilm
    convenience init(from imdbFilm: IMDBFilm) {
        self.init(
            imdbID: imdbFilm.imdbID,
            title: imdbFilm.title,
            year: imdbFilm.year,
            posterURL: imdbFilm.poster,
            genres: imdbFilm.genreList,
            director: imdbFilm.director,
            runtime: imdbFilm.runtime,
            plot: imdbFilm.plot
        )
    }
    
    // Convenience initializer from OMDBSearchItem
    convenience init(from searchItem: OMDBSearchItem) {
        self.init(
            imdbID: searchItem.imdbID,
            title: searchItem.title,
            year: searchItem.year,
            posterURL: searchItem.poster,
            genres: []
        )
    }
}

// MARK: - Computed Properties
extension MyFilm {
    var displayYear: String {
        year ?? "Unknown Year"
    }
    
    var isRated: Bool {
        myRating != nil
    }
    
    var watchStatusText: String {
        if watched {
            if let date = dateWatched {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Watched on \(formatter.string(from: date))"
            }
            return "Watched"
        }
        return "Not watched"
    }
    
    var ratingText: String? {
        guard let rating = myRating else { return nil }
        return "\(rating)/10"
    }
}