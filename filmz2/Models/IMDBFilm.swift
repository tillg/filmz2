/**
 * IMDBFilm Model - OMDB API Film Data Structure
 *
 * This model represents the film data structure returned by the OMDB API.
 * It's designed to handle the API's response format with proper optional 
 * handling for fields that may be missing or contain "N/A" values.
 *
 * Architecture Role:
 * - Data transfer object for OMDB API responses
 * - Used throughout the app for displaying film information
 * - Supports both API responses and persistent caching with SwiftData
 * - Provides computed properties for UI convenience
 *
 * Key Features:
 * - Custom decoding to handle "N/A" values as nil
 * - Computed properties for common UI needs (posterURL, genreList, etc.)
 * - Support for both search results and detailed film data
 * - Ratings from multiple sources (IMDB, Rotten Tomatoes, Metacritic)
 *
 * Required Fields:
 * - imdbID: Unique identifier (used as primary key)
 * - title: Film title (always present in API responses)
 *
 * All other fields are optional as they may be missing from API responses,
 * especially for older or less popular films.
 */

import Foundation
@preconcurrency import SwiftData

/// Represents a film from the IMDB/OMDb API
/// Conforms to the OMDb API response structure with proper optional handling
/// Only imdbID and title are guaranteed - all other fields may be missing
@Model
final class IMDBFilm: Codable, Identifiable, @unchecked Sendable {
    // MARK: - Core Properties
    
    /// Unique identifier using imdbID for consistency with external APIs
    var id: String { imdbID }
    
    // Required fields - these must exist
    var imdbID: String = ""
    var title: String = ""
    
    // Optional fields - may be missing or "N/A" from API
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
    var ratings: [Rating]?
    var metascore: String?
    var imdbRating: String?
    var imdbVotes: String?
    var type: String?
    var response: String?
    
    // Cache metadata
    var lastFetched: Date = Date()
    var dataVersion: Int = 1
    
    // MARK: - Nested Types
    
    struct Rating: Codable, Sendable {
        let source: String
        let value: String
        
        enum CodingKeys: String, CodingKey {
            case source = "Source"
            case value = "Value"
        }
    }
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case imdbID
        case year = "Year"
        case rated = "Rated"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case language = "Language"
        case country = "Country"
        case awards = "Awards"
        case poster = "Poster"
        case ratings = "Ratings"
        case metascore = "Metascore"
        case imdbRating
        case imdbVotes
        case type = "Type"
        case response = "Response"
    }
    
    // MARK: - Initializers
    
    init() {
        // SwiftData requires a default initializer
    }
    
    // MARK: - Custom Decoding
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        title = try container.decode(String.self, forKey: .title)
        imdbID = try container.decode(String.self, forKey: .imdbID)
        
        // Optional fields with "N/A" handling
        year = Self.decodeOptionalString(from: container, forKey: .year)
        rated = Self.decodeOptionalString(from: container, forKey: .rated)
        released = Self.decodeOptionalString(from: container, forKey: .released)
        runtime = Self.decodeOptionalString(from: container, forKey: .runtime)
        genre = Self.decodeOptionalString(from: container, forKey: .genre)
        director = Self.decodeOptionalString(from: container, forKey: .director)
        writer = Self.decodeOptionalString(from: container, forKey: .writer)
        actors = Self.decodeOptionalString(from: container, forKey: .actors)
        plot = Self.decodeOptionalString(from: container, forKey: .plot)
        language = Self.decodeOptionalString(from: container, forKey: .language)
        country = Self.decodeOptionalString(from: container, forKey: .country)
        awards = Self.decodeOptionalString(from: container, forKey: .awards)
        poster = Self.decodeOptionalString(from: container, forKey: .poster)
        metascore = Self.decodeOptionalString(from: container, forKey: .metascore)
        imdbRating = Self.decodeOptionalString(from: container, forKey: .imdbRating)
        imdbVotes = Self.decodeOptionalString(from: container, forKey: .imdbVotes)
        type = Self.decodeOptionalString(from: container, forKey: .type)
        response = Self.decodeOptionalString(from: container, forKey: .response)
        
        // Handle ratings array
        ratings = try? container.decode([Rating].self, forKey: .ratings)
        
        // Cache metadata - set defaults when decoding from API
        lastFetched = Date()
        dataVersion = 1
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(imdbID, forKey: .imdbID)
        try container.encodeIfPresent(year, forKey: .year)
        try container.encodeIfPresent(rated, forKey: .rated)
        try container.encodeIfPresent(released, forKey: .released)
        try container.encodeIfPresent(runtime, forKey: .runtime)
        try container.encodeIfPresent(genre, forKey: .genre)
        try container.encodeIfPresent(director, forKey: .director)
        try container.encodeIfPresent(writer, forKey: .writer)
        try container.encodeIfPresent(actors, forKey: .actors)
        try container.encodeIfPresent(plot, forKey: .plot)
        try container.encodeIfPresent(language, forKey: .language)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(awards, forKey: .awards)
        try container.encodeIfPresent(poster, forKey: .poster)
        try container.encodeIfPresent(ratings, forKey: .ratings)
        try container.encodeIfPresent(metascore, forKey: .metascore)
        try container.encodeIfPresent(imdbRating, forKey: .imdbRating)
        try container.encodeIfPresent(imdbVotes, forKey: .imdbVotes)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(response, forKey: .response)
    }
    
    /// Helper method to decode strings and treat "N/A" as nil
    private static func decodeOptionalString(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> String? {
        guard let value = try? container.decode(String.self, forKey: key),
              !value.isEmpty,
              value != "N/A" else {
            return nil
        }
        return value
    }
    
}

// MARK: - Convenience Initializers

extension IMDBFilm {
    /// Convenience initializer for testing and manual creation
    convenience init(
        title: String,
        imdbID: String,
        year: String? = nil,
        rated: String? = nil,
        released: String? = nil,
        runtime: String? = nil,
        genre: String? = nil,
        director: String? = nil,
        writer: String? = nil,
        actors: String? = nil,
        plot: String? = nil,
        language: String? = nil,
        country: String? = nil,
        awards: String? = nil,
        poster: String? = nil,
        ratings: [Rating]? = nil,
        metascore: String? = nil,
        imdbRating: String? = nil,
        imdbVotes: String? = nil,
        type: String? = nil,
        response: String? = nil,
        lastFetched: Date = Date(),
        dataVersion: Int = 1
    ) {
        self.init()
        self.title = title
        self.imdbID = imdbID
        self.year = year
        self.rated = rated
        self.released = released
        self.runtime = runtime
        self.genre = genre
        self.director = director
        self.writer = writer
        self.actors = actors
        self.plot = plot
        self.language = language
        self.country = country
        self.awards = awards
        self.poster = poster
        self.ratings = ratings
        self.metascore = metascore
        self.imdbRating = imdbRating
        self.imdbVotes = imdbVotes
        self.type = type
        self.response = response
        self.lastFetched = lastFetched
        self.dataVersion = dataVersion
    }
}

// MARK: - Cache Management

extension IMDBFilm {
    /// Returns true if the cached data is older than 30 days
    var isStale: Bool {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        return lastFetched < thirtyDaysAgo
    }
    
    /// Updates the cache metadata when refreshing from API
    func updateCacheMetadata() {
        lastFetched = Date()
        dataVersion += 1
    }
}

// MARK: - Computed Properties

extension IMDBFilm {
    /// Returns the poster URL if valid, nil otherwise
    var posterURL: URL? {
        guard let poster = poster else { return nil }
        return URL(string: poster)
    }
    
    /// Returns genres as an array for display
    var genreList: [String] {
        guard let genre = genre else { return [] }
        return genre.components(separatedBy: ", ").filter { !$0.isEmpty }
    }
    
    /// Returns actors as an array for display
    var actorList: [String] {
        guard let actors = actors else { return [] }
        return actors.components(separatedBy: ", ").filter { !$0.isEmpty }
    }
    
    /// Returns the IMDB rating as a formatted string
    var formattedIMDBRating: String? {
        guard let rating = imdbRating else { return nil }
        return "\(rating)/10"
    }
    
    /// Returns the Rotten Tomatoes rating if available
    var rottenTomatoesRating: String? {
        ratings?.first { $0.source == "Rotten Tomatoes" }?.value
    }
    
    /// Returns the Metacritic rating if available
    var metacriticRating: String? {
        guard let score = metascore else { return nil }
        return "\(score)/100"
    }
    
    /// Returns a formatted runtime string, nil if not available
    var formattedRuntime: String? {
        runtime
    }
    
    /// Returns a formatted year and runtime combination
    var yearAndRuntime: String {
        switch (year, runtime) {
        case let (year?, runtime?):
            return "\(year) • \(runtime)"
        case let (year?, nil):
            return year
        case let (nil, runtime?):
            return runtime
        case (nil, nil):
            return "Year unknown"
        }
    }
    
    /// Returns true if the film has valid rating information
    var hasRatings: Bool {
        imdbRating != nil || !(ratings?.isEmpty ?? true)
    }
    
    /// Returns the display year, with fallback
    var displayYear: String? {
        year
    }
    
    /// Returns the rated classification (PG, R, etc.)
    var ratingClassification: String? {
        rated
    }
    
    /// Returns the writer field (alias for consistency with MyFilm)
    var writers: String? {
        writer
    }
}

// MARK: - Sample Data

#if DEBUG
extension IMDBFilm {
    static let missionImpossible = IMDBFilm(
        title: "Mission: Impossible - The Final Reckoning",
        imdbID: "tt9603208",
        year: "2025",
        released: "23 May 2025",
        runtime: "169 min",
        genre: "Action, Adventure, Thriller",
        director: "Christopher McQuarrie",
        writer: "Bruce Geller, Erik Jendresen, Christopher McQuarrie",
        actors: "Vanessa Kirby, Tom Cruise, Hayley Atwell",
        plot: "Our lives are the sum of our choices. Tom Cruise is Ethan Hunt in Mission: Impossible - The Final Reckoning.",
        language: "English",
        country: "United States, United Kingdom",
        awards: "1 nomination total",
        poster: "https://m.media-amazon.com/images/M/MV5BZGQ5NGEyYTItMjNiMi00Y2EwLTkzOWItMjc5YjJiMjMyNTI0XkEyXkFqcGc@._V1_SX300.jpg",
        ratings: [Rating(source: "Rotten Tomatoes", value: "79%")],
        type: "movie",
        response: "True"
    )
    
    static let darkKnight = IMDBFilm(
        title: "The Dark Knight",
        imdbID: "tt0468569",
        year: "2008",
        rated: "PG-13",
        released: "18 Jul 2008",
        runtime: "152 min",
        genre: "Action, Crime, Drama",
        director: "Christopher Nolan",
        writer: "Jonathan Nolan, Christopher Nolan, Bob Kane",
        actors: "Christian Bale, Heath Ledger, Aaron Eckhart",
        plot: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.",
        language: "English, Mandarin",
        country: "United States, United Kingdom",
        awards: "Won 2 Oscars. 159 wins & 163 nominations total",
        poster: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg",
        ratings: [
            Rating(source: "Internet Movie Database", value: "9.0/10"),
            Rating(source: "Rotten Tomatoes", value: "94%"),
            Rating(source: "Metacritic", value: "84/100")
        ],
        metascore: "84",
        imdbRating: "9.0",
        imdbVotes: "2,654,264",
        type: "movie",
        response: "True"
    )
    
    static let inception = IMDBFilm(
        title: "Inception",
        imdbID: "tt1375666",
        year: "2010",
        rated: "PG-13",
        released: "16 Jul 2010",
        runtime: "148 min",
        genre: "Action, Sci-Fi, Thriller",
        director: "Christopher Nolan",
        writer: "Christopher Nolan",
        actors: "Leonardo DiCaprio, Marion Cotillard, Elliot Page",
        plot: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O., but his tragic past may doom the project and his team to disaster.",
        language: "English, Japanese, French",
        country: "United States, United Kingdom",
        awards: "Won 4 Oscars. 157 wins & 220 nominations total",
        poster: "https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_SX300.jpg",
        ratings: [
            Rating(source: "Internet Movie Database", value: "8.8/10"),
            Rating(source: "Rotten Tomatoes", value: "87%"),
            Rating(source: "Metacritic", value: "74/100")
        ],
        metascore: "74",
        imdbRating: "8.8",
        imdbVotes: "2,364,425",
        type: "movie",
        response: "True"
    )
    
    /// Sample film with minimal data to test optional field handling
    static let minimalFilm = IMDBFilm(
        title: "Unknown Film",
        imdbID: "tt0000000"
        // All other fields remain nil to test conditional UI rendering
    )
    
    /// Sample films for testing and previews
    static let sampleFilms = [missionImpossible, darkKnight, inception]
}
#endif