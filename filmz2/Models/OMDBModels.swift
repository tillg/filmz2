/**
 * OMDBModels - Raw API Response Models
 *
 * This file contains the raw data structures used for parsing OMDB API responses.
 * These models map directly to the JSON structure returned by the API and handle
 * the specific field naming conventions used by OMDB.
 *
 * Architecture Role:
 * - Low-level API response parsing
 * - Converted to higher-level models (IMDBFilm) for use in the app
 * - Handles API-specific quirks (capitalized field names, string booleans)
 * - Provides clean separation between API format and app's internal format
 *
 * Model Types:
 * 1. OMDBSearchResponse - Response from search queries
 *    - Contains array of search results
 *    - Includes pagination info (totalResults)
 *    - Error handling for failed searches
 *
 * 2. OMDBSearchItem - Individual search result
 *    - Limited data (title, year, type, poster)
 *    - Used in search results list
 *    - Requires additional API call for full details
 *
 * 3. OMDBDetailResponse - Full movie details
 *    - Complete film information
 *    - All fields are optional (API may return "N/A")
 *    - Includes ratings from multiple sources
 *
 * 4. OMDBRating - Rating from a specific source
 *    - Source name and rating value
 *    - Used within OMDBDetailResponse
 *
 * Note: These models use CodingKeys to map between API field names
 * (which use PascalCase) and Swift property names (which use camelCase).
 */

import Foundation

struct OMDBSearchResponse: Codable {
    let search: [OMDBSearchItem]?
    let totalResults: String?
    let response: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
        case error = "Error"
    }
}

struct OMDBSearchItem: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
}

struct OMDBDetailResponse: Codable {
    let title: String
    let year: String
    let rated: String?
    let released: String?
    let runtime: String?
    let genre: String?
    let director: String?
    let writer: String?
    let actors: String?
    let plot: String?
    let language: String?
    let country: String?
    let awards: String?
    let poster: String?
    let ratings: [OMDBRating]?
    let metascore: String?
    let imdbRating: String?
    let imdbVotes: String?
    let imdbID: String
    let type: String
    let dvd: String?
    let boxOffice: String?
    let production: String?
    let website: String?
    let response: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
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
        case imdbID
        case type = "Type"
        case dvd = "DVD"
        case boxOffice = "BoxOffice"
        case production = "Production"
        case website = "Website"
        case response = "Response"
        case error = "Error"
    }
}

struct OMDBRating: Codable {
    let source: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}