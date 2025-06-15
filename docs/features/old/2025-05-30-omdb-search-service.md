# Feature: OMDB Search Service

## Overview

A service that interfaces with the OMDB API to search for films and series, providing a clean Swift interface for film discovery.

## Service Interface

```swift
protocol OMDBSearchServiceProtocol {
    func searchFilms(query: String, year: String? = nil, type: MediaType? = nil, page: Int = 1) async throws -> SearchResult
    func getFilm(byID: String) async throws -> IMDBFilm
    func getFilm(byTitle: String, year: String? = nil) async throws -> IMDBFilm
}

enum MediaType: String {
    case movie
    case series
    case episode
}

struct SearchResult {
    let films: [IMDBFilm]
    let totalResults: Int
    let currentPage: Int
    let totalPages: Int
}
```

## API Endpoints

- **Search**: `/?s={title}&y={year}&type={type}&page={page}`
- **Get by ID**: `/?i={imdbID}`
- **Get by Title**: `/?t={title}&y={year}`

## Features

- Search by title with optional year and type filters
- Pagination support (10 items per page)
- Get specific film by IMDB ID or exact title
- Simple in-memory caching for current session
- Basic retry logic for failed requests
- 30-second timeout for all requests

## Testing Requirements

- Mock URLSession for unit tests
- Test all endpoint variations
- Test error handling (network failures, invalid responses)
- Test caching behavior
- Integration tests with real API (test key)

## Usage Example

```swift
let service = OMDBSearchService(apiKey: "your-api-key")

// Basic search (defaults to page 1)
let results = try await service.searchFilms(query: "Matrix")

// Search with filters
let movies = try await service.searchFilms(query: "Star Wars", year: "1977", type: .movie)

// Search with pagination
let page2 = try await service.searchFilms(query: "Batman", page: 2)

// Get specific film
let film = try await service.getFilm(byID: "tt0133093")
```

## Implementation Notes

- API key stored in environment variables
- All requests use HTTPS
- Input validation for search queries
- Maximum 5 concurrent requests

## References

- [OMDB API Documentation](http://www.omdbapi.com/)
- [API Usage Examples](docs/OMDb_API_example.json)
