# Data Structures

The key data entities used throughout the application.

[TOC]

## MyFilm

The data about a film that I maintain. Some fields of it:

- id: UUID
- imdbFilmId: The film id from IMDB
- myRating: Int 0..10
- dateAdded: Date
- watched: Bool
- dateWatched: Date
- audience: Enum AudienceType("Me alone", "Me and partner", "Family")
- recommendedBy: String

**Status**: Not yet implemented - placeholder `Item.swift` exists with basic SwiftData structure.

TODO:

- Shows & Series: At a later stage I will have to properly deal with shows, seasons, episodes... Currently a show is just one film.

## IMDBFilm

The data from the OMDb API about a film. This struct handles the complete response from the OMDb API with robust optional field handling.

### Core Properties

**Required fields** (always present):

- `title: String` - Film title
- `imdbID: String` - Unique IMDB identifier, also serves as the `id` for Identifiable conformance

**Optional fields** (may be missing or "N/A" from API):

- `year: String?` - Release year
- `rated: String?` - Rating classification (PG, R, etc.)
- `released: String?` - Release date
- `runtime: String?` - Film duration
- `genre: String?` - Comma-separated genres
- `director: String?` - Director name(s)
- `writer: String?` - Writer name(s)
- `actors: String?` - Comma-separated actor names
- `plot: String?` - Film synopsis
- `language: String?` - Primary language(s)
- `country: String?` - Country of origin
- `awards: String?` - Awards and nominations
- `poster: String?` - Poster image URL
- `metascore: String?` - Metacritic score
- `imdbRating: String?` - IMDB rating value
- `imdbVotes: String?` - Number of IMDB votes
- `type: String?` - Content type (movie, series, etc.)
- `response: String?` - API response status

### Nested Types

#### Rating

```swift
struct Rating: Codable {
    let source: String  // e.g., "Internet Movie Database"
    let value: String   // e.g., "9.0/10"
}
```

### Computed Properties

**URL Conversion**:

- `posterURL: URL?` - Converts poster string to URL, returns nil if invalid

**Array Conversions**:

- `genreList: [String]` - Splits genre string into array, filters empty values
- `actorList: [String]` - Splits actors string into array, filters empty values

**Formatted Ratings**:

- `formattedIMDBRating: String?` - Returns "X.X/10" format or nil
- `rottenTomatoesRating: String?` - Extracts RT rating from ratings array
- `metacriticRating: String?` - Returns "XX/100" format from metascore

**Display Helpers**:

- `yearAndRuntime: String` - Combines year and runtime with fallbacks
- `hasRatings: Bool` - True if any rating data is available
- `ratingClassification: String?` - Returns the rated field value

### Custom Decoding

The model implements custom JSON decoding that:

- Treats "N/A" values as nil
- Handles missing optional fields gracefully
- Uses proper CodingKeys for API field mapping
- Safely decodes the ratings array

### Sample Data

Includes comprehensive sample data for testing and previews:

- `darkKnight` - Complete film with all fields
- `missionImpossible` - Film with some missing fields
- `inception` - Another complete example
- `minimalFilm` - Film with only required fields for testing edge cases

## RatingDisplayInfo

A supporting structure used by the ViewModel for rating display:

```swift
struct RatingDisplayInfo {
    let source: String    // "IMDB", "Rotten Tomatoes", "Metacritic"
    let value: String     // Formatted rating value
    let icon: String      // SF Symbol name
    let color: Color      // Source-specific color
}
```

This structure standardizes rating information for consistent UI display across different rating sources.

## ViewModels

### IMDBFilmDetailViewModel

Business logic layer for film detail presentation:

**Published Properties**:

- `film: IMDBFilm` - The source film data
- `isImageLoading: Bool` - Poster loading state
- `imageLoadError: Error?` - Poster loading errors

**Computed Properties** (all handle optional fields gracefully):

- `titleWithYear: String` - Formatted title with year
- `genreChips: [String]` - Genre list for pill display
- `formattedActors: String?` - Comma-separated actors or nil
- `formattedWriters: String?` - Writer credits or nil
- `directorInfo: String?` - "Directed by X" format or nil
- `releaseInfo: String?` - "Released X" format or nil
- `originInfo: String?` - Language and country info or nil
- `awardsInfo: String?` - Awards text or nil
- `ratingBadge: String?` - Rating classification or nil
- `availableRatings: [RatingDisplayInfo]` - All available ratings formatted for display

**Utility Methods**:

- `formattedVotes() -> String?` - Formats vote count
- `shouldTruncatePlot(maxLength:) -> Bool` - Determines if plot needs truncation
- `truncatedPlot(maxLength:) -> String` - Returns truncated plot with ellipsis

## Architecture Notes

**Identifiable Conformance**: Uses `imdbID` as the unique identifier for SwiftUI list performance.

**Optional Field Strategy**: Only `title` and `imdbID` are required. All other fields are optional to handle incomplete API responses gracefully.

**"N/A" Handling**: Custom decoding treats OMDb API "N/A" responses as nil rather than string values, enabling proper optional chaining in the UI.

**Preview Support**: Comprehensive sample data enables rich SwiftUI previews during development.

## Search-Related Data Structures

### OMDBSearchResponse

The raw response from the OMDb API when performing a search:

```swift
struct OMDBSearchResponse: Codable {
    let search: [OMDBSearchItem]?  // Array of search results
    let totalResults: String?       // Total number of results
    let response: String           // "True" or "False"
    let error: String?             // Error message if response is "False"
}
```

**CodingKeys**: Maps `search` to "Search" and `response` to "Response" for API compatibility.

### OMDBSearchItem

Individual search result item from the OMDb API:

```swift
struct OMDBSearchItem: Codable {
    let title: String      // Movie title
    let year: String       // Release year
    let imdbID: String     // IMDB identifier
    let type: String       // "movie", "series", or "episode"
    let poster: String?    // Poster URL (optional)
}
```

**CodingKeys**: Maps to capitalized API field names (Title, Year, Type, Poster).

### SearchResult

Internal structure for processed search results:

```swift
struct SearchResult {
    let films: [IMDBFilm]     // Array of film objects
    let totalResults: Int     // Total count
    let currentPage: Int      // Current page number
    let totalPages: Int       // Total pages available
}
```

### MediaType

Enum representing the type of media content:

```swift
enum MediaType: String {
    case movie
    case series
    case episode
}
```

Used for filtering search results by content type.

### OMDBError

Comprehensive error handling for API operations:

```swift
enum OMDBError: Error, LocalizedError {
    case invalidAPIKey           // API key is invalid
    case movieNotFound          // No results found
    case invalidResponse        // Malformed response
    case networkError(Error)    // Network-related errors
    case dailyLimitExceeded     // API rate limit hit
    case decodingError(Error)   // JSON decoding failed
    case unknownError(String)   // Other errors with message
}
```

Each case provides a localized error description for user-friendly error messages.

## API Integration Models

### OMDBDetailResponse

Complete response structure for detailed film information (used internally by OMDBSearchService):

Contains all fields from the OMDb API including:
- Basic info: title, year, rated, released, runtime
- Creative: genre, director, writer, actors, plot
- Metadata: language, country, awards, poster
- Ratings: ratings array, metascore, imdbRating, imdbVotes
- Technical: imdbID, type, dvd, boxOffice, production, website
- Response status: response, error

### OMDBRating

Rating information from various sources:

```swift
struct OMDBRating: Codable {
    let source: String  // "Internet Movie Database", "Rotten Tomatoes", etc.
    let value: String   // "8.5/10", "94%", etc.
}
```

## Service Protocols

### OMDBSearchServiceProtocol

Defines the contract for search service implementations:

```swift
protocol OMDBSearchServiceProtocol {
    func searchFilms(query: String, year: String?, type: MediaType?, page: Int) async throws -> SearchResult
    func searchFilmsRaw(query: String, year: String?, type: MediaType?, page: Int) async throws -> OMDBSearchResponse
    func getFilm(byID: String) async throws -> IMDBFilm
    func getFilm(byTitle: String, year: String?) async throws -> IMDBFilm
    func getFilmDetails(imdbID: String) async throws -> IMDBFilm
}
```

### URLSessionProtocol

Enables testing by abstracting URLSession:

```swift
protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}
```

URLSession conforms to this protocol by default, allowing easy mocking in tests.
