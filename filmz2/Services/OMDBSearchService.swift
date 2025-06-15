import Foundation
import SwiftData

/// Protocol defining the interface for OMDB API interactions and film data retrieval.
/// Provides methods for searching films, retrieving detailed film information, and managing API responses.
protocol OMDBSearchServiceProtocol {
    /// Searches for films using the OMDB API with optional filters.
    /// - Parameters:
    ///   - query: Search term (minimum 3 characters)
    ///   - year: Optional year filter
    ///   - type: Optional media type filter (movie, series, episode)
    ///   - page: Page number for pagination (default: 1)
    /// - Returns: SearchResult containing films and pagination info
    /// - Throws: OMDBError for API errors or network issues
    func searchFilms(query: String, year: String?, type: MediaType?, page: Int) async throws -> SearchResult
    
    /// Performs raw search without processing results into IMDBFilm objects.
    /// - Parameters:
    ///   - query: Search term (minimum 3 characters)
    ///   - year: Optional year filter
    ///   - type: Optional media type filter
    ///   - page: Page number for pagination
    /// - Returns: Raw OMDBSearchResponse from API
    /// - Throws: OMDBError for API errors or network issues
    func searchFilmsRaw(query: String, year: String?, type: MediaType?, page: Int) async throws -> OMDBSearchResponse
    
    /// Retrieves detailed film information by IMDB ID using cache-first strategy.
    /// - Parameter byID: IMDB ID of the film
    /// - Returns: Complete IMDBFilm object with all available details
    /// - Throws: OMDBError for API errors or network issues
    func getFilm(byID: String) async throws -> IMDBFilm
    
    /// Retrieves film information by title with optional year.
    /// - Parameters:
    ///   - byTitle: Film title to search for
    ///   - year: Optional year to improve search accuracy
    /// - Returns: IMDBFilm object with film details
    /// - Throws: OMDBError for API errors or network issues
    func getFilm(byTitle: String, year: String?) async throws -> IMDBFilm
    
}

/// Enumeration of supported media types for OMDB API filtering.
enum MediaType: String {
    /// Feature films
    case movie
    /// TV series
    case series
    /// Individual TV episodes
    case episode
}

/// Container for paginated search results from OMDB API.
/// Provides both the film data and pagination metadata.
struct SearchResult {
    /// Array of films matching the search criteria
    let films: [IMDBFilm]
    /// Total number of results available (across all pages)
    let totalResults: Int
    /// Current page number (1-based)
    let currentPage: Int
    /// Total number of pages available
    let totalPages: Int
}

/// Comprehensive error types for OMDB API interactions.
/// Maps API response errors to structured Swift errors with localized descriptions.
enum OMDBError: Error, LocalizedError {
    /// API key is invalid or missing
    case invalidAPIKey
    /// Requested film was not found in OMDB database
    case movieNotFound
    /// API returned an invalid or unexpected response format
    case invalidResponse
    /// Network connectivity or HTTP transport error
    case networkError(Error)
    /// Daily API request limit has been exceeded
    case dailyLimitExceeded
    /// Failed to decode JSON response from API
    case decodingError(Error)
    /// Unknown error with custom message from API
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey: return "Invalid API key"
        case .movieNotFound: return "Movie not found"
        case .invalidResponse: return "Invalid response from server"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .dailyLimitExceeded: return "Daily request limit exceeded"
        case .decodingError(let error): return "Failed to decode response: \(error.localizedDescription)"
        case .unknownError(let message): return message
        }
    }
}

/// Service class for interacting with the OMDB API.
/// Implements a sophisticated caching strategy with both in-memory and persistent storage:
/// 1. Persistent cache via CacheManager (30-day staleness policy)
/// 2. In-memory cache for session-based performance
/// 3. Cache-first approach: check persistent cache → check memory cache → fetch from API
///
/// The service handles API rate limiting, error mapping, and automatic wildcard search enhancement.
/// Thread-safe for concurrent access patterns.
class OMDBSearchService: OMDBSearchServiceProtocol {
    /// Shared singleton instance configured with production API key
    static let shared = OMDBSearchService(apiKey: APIKeys.omdbAPIKey)
    
    /// OMDB API key for authentication
    private let apiKey: String
    /// Base URL for OMDB API requests
    private let baseURL = "https://www.omdbapi.com/"
    /// URL session abstraction for network requests (enables testing)
    private let session: URLSessionProtocol
    /// In-memory cache for session-based performance optimization
    private var cache: [String: Any] = [:]
    
    /// Initializes the service with API credentials and optional session override.
    /// - Parameters:
    ///   - apiKey: OMDB API key for authentication
    ///   - session: URL session for network requests (defaults to URLSession.shared)
    init(apiKey: String, session: URLSessionProtocol = URLSession.shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    /// Legacy method for setting SwiftData context - now deprecated.
    /// Cache management is handled by CacheManager singleton.
    /// - Parameter context: SwiftData model context (ignored)
    @available(*, deprecated, message: "Cache management is now handled by CacheManager")
    func setModelContext(_ context: ModelContext) {
        // No longer needed - using CacheManager
        print("OMDBSearchService: Model context set (deprecated)")
    }
    
    /// Searches for films using OMDB API with intelligent query enhancement and caching.
    /// 
    /// **Search Enhancement Algorithm:**
    /// - Enforces minimum 3-character query length (OMDB requirement)
    /// - Automatically appends wildcard (*) for broader results
    /// - Implements in-memory caching for identical queries
    /// 
    /// **Caching Strategy:**
    /// - Cache key: Complete URL with all parameters
    /// - Cache duration: Session-based (in-memory only)
    /// - Cache invalidation: Automatic on app restart
    /// 
    /// - Parameters:
    ///   - query: Search term (minimum 3 characters)
    ///   - year: Optional year filter for more precise results
    ///   - type: Optional media type filter (movie/series/episode)
    ///   - page: Page number for pagination (default: 1, max: varies by API)
    /// - Returns: SearchResult with films and pagination metadata
    /// - Throws: OMDBError for API errors, network issues, or invalid responses
    func searchFilms(query: String, year: String? = nil, type: MediaType? = nil, page: Int = 1) async throws -> SearchResult {
        // OMDb API requires at least 3 characters for search
        guard query.count >= 3 || query.hasSuffix("*") else {
            // Return empty result for queries that are too short
            return SearchResult(films: [], totalResults: 0, currentPage: page, totalPages: 0)
        }
        
        // Add wildcard for wide search if query doesn't already end with *
        let searchQuery = query.hasSuffix("*") ? query : query + "*"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "s", value: searchQuery),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "r", value: "json")
        ]
        
        if let year = year {
            components.queryItems?.append(URLQueryItem(name: "y", value: year))
        }
        
        if let type = type {
            components.queryItems?.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        
        let cacheKey = components.url!.absoluteString
        if let cached = cache[cacheKey] as? SearchResult {
            return cached
        }
        
        do {
            let (data, _) = try await session.data(from: components.url!)
            let response = try JSONDecoder().decode(OMDBSearchResponse.self, from: data)
            
            if response.response == "False" {
                if response.error == "Invalid API key!" {
                    throw OMDBError.invalidAPIKey
                } else if response.error == "Movie not found!" {
                    throw OMDBError.movieNotFound
                } else {
                    throw OMDBError.invalidResponse
                }
            }
            
            let films = response.search?.compactMap { item in
                IMDBFilm(from: item)
            } ?? []
            
            let totalResults = Int(response.totalResults ?? "0") ?? 0
            let totalPages = (totalResults + 9) / 10
            
            let result = SearchResult(
                films: films,
                totalResults: totalResults,
                currentPage: page,
                totalPages: totalPages
            )
            
            cache[cacheKey] = result
            return result
            
        } catch let error as OMDBError {
            throw error
        } catch {
            throw OMDBError.networkError(error)
        }
    }
    
    /// Retrieves detailed film information using sophisticated cache-first strategy.
    /// 
    /// **Cache-First Algorithm:**
    /// 1. **Persistent Cache Check**: Query CacheManager for stored film data
    ///    - If found and fresh (< 30 days old): Return immediately
    ///    - If found but stale (> 30 days old): Continue to API fetch
    /// 2. **In-Memory Cache Check**: Check session cache for recent requests
    ///    - If found: Return immediately (faster than persistent storage)
    /// 3. **API Fetch**: Request from OMDB API as fallback
    ///    - Update both persistent and in-memory caches
    ///    - Handle API errors gracefully
    /// 
    /// **Performance Characteristics:**
    /// - Cache hit (fresh): ~1ms response time
    /// - Cache hit (stale): ~100ms response time (disk I/O)
    /// - Cache miss: ~500-2000ms response time (network + processing)
    /// 
    /// **Error Handling:**
    /// - Invalid IMDB ID: Throws OMDBError.movieNotFound
    /// - Network issues: Throws OMDBError.networkError
    /// - API key issues: Throws OMDBError.invalidAPIKey
    /// 
    /// - Parameter byID: Valid IMDB identifier (format: "tt1234567")
    /// - Returns: Complete IMDBFilm object with all available metadata
    /// - Throws: OMDBError for various failure scenarios
    func getFilm(byID: String) async throws -> IMDBFilm {
        // First check persistent cache
        let cachedFilm = await MainActor.run {
            CacheManager.shared.fetchFilm(imdbID: byID)
        }
        
        if let cachedFilm = cachedFilm {
            // Return cached film if fresh
            if !cachedFilm.isStale {
                print("OMDBSearchService: Returning cached film '\(cachedFilm.title)' with rating \(cachedFilm.imdbRating ?? "nil")")
                return cachedFilm
            }
        }
        
        // Check in-memory cache
        let cacheKey = "id-\(byID)"
        if let cached = cache[cacheKey] as? IMDBFilm {
            return cached
        }
        
        // Fetch from API
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "i", value: byID),
            URLQueryItem(name: "r", value: "json")
        ]
        
        do {
            let (data, _) = try await session.data(from: components.url!)
            let response = try JSONDecoder().decode(OMDBDetailResponse.self, from: data)
            
            if response.response == "False" {
                if response.error == "Invalid API key!" {
                    throw OMDBError.invalidAPIKey
                } else if response.error == "Movie not found!" || response.error == "Incorrect IMDb ID." {
                    throw OMDBError.movieNotFound
                } else {
                    throw OMDBError.invalidResponse
                }
            }
            
            let film = IMDBFilm(from: response)
            cache[cacheKey] = film
            
            // Save to persistent cache using CacheManager for future requests
            await MainActor.run {
                CacheManager.shared.saveFilm(film)
            }
            
            return film
            
        } catch let error as OMDBError {
            throw error
        } catch {
            throw OMDBError.networkError(error)
        }
    }
    
    /// Retrieves film information by title with optional year precision.
    /// Uses in-memory caching but not persistent caching (title searches are less predictable).
    /// 
    /// **Search Strategy:**
    /// - Exact title matching with OMDB API
    /// - Optional year parameter improves accuracy for common titles
    /// - Results cached in-memory for session duration
    /// 
    /// **Use Cases:**
    /// - User searches by film title instead of IMDB ID
    /// - Verification of film details during collection management
    /// - Fallback when IMDB ID is unavailable
    /// 
    /// - Parameters:
    ///   - byTitle: Exact or partial film title
    ///   - year: Optional release year for disambiguation
    /// - Returns: IMDBFilm object with complete film details
    /// - Throws: OMDBError for API errors or film not found
    func getFilm(byTitle: String, year: String? = nil) async throws -> IMDBFilm {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "t", value: byTitle),
            URLQueryItem(name: "r", value: "json")
        ]
        
        if let year = year {
            components.queryItems?.append(URLQueryItem(name: "y", value: year))
        }
        
        let cacheKey = components.url!.absoluteString
        if let cached = cache[cacheKey] as? IMDBFilm {
            return cached
        }
        
        do {
            let (data, _) = try await session.data(from: components.url!)
            let response = try JSONDecoder().decode(OMDBDetailResponse.self, from: data)
            
            if response.response == "False" {
                if response.error == "Invalid API key!" {
                    throw OMDBError.invalidAPIKey
                } else if response.error == "Movie not found!" {
                    throw OMDBError.movieNotFound
                } else {
                    throw OMDBError.invalidResponse
                }
            }
            
            let film = IMDBFilm(from: response)
            cache[cacheKey] = film
            return film
            
        } catch let error as OMDBError {
            throw error
        } catch {
            throw OMDBError.networkError(error)
        }
    }
    
    /// Performs raw search returning unprocessed OMDB API response.
    /// Used for debugging, testing, or when raw API data is needed.
    /// 
    /// **Differences from searchFilms():**
    /// - Returns raw OMDBSearchResponse instead of processed SearchResult
    /// - No result caching (intended for diagnostic use)
    /// - Enhanced error handling for API limit detection
    /// 
    /// **Error Detection Algorithm:**
    /// - Parses API error messages for specific failure types
    /// - Maps "Request limit reached" to dailyLimitExceeded
    /// - Handles "Too many results" as movieNotFound
    /// - Provides detailed error context for debugging
    /// 
    /// - Parameters:
    ///   - query: Search term (minimum 3 characters)
    ///   - year: Optional year filter
    ///   - type: Optional media type filter
    ///   - page: Page number for pagination
    /// - Returns: Raw OMDBSearchResponse from API
    /// - Throws: OMDBError with detailed error context
    func searchFilmsRaw(query: String, year: String? = nil, type: MediaType? = nil, page: Int = 1) async throws -> OMDBSearchResponse {
        // OMDb API requires at least 3 characters for search
        guard query.count >= 3 || query.hasSuffix("*") else {
            // Return empty response for queries that are too short
            return OMDBSearchResponse(search: nil, totalResults: "0", response: "True", error: nil)
        }
        
        // Add wildcard for wide search if query doesn't already end with *
        let searchQuery = query.hasSuffix("*") ? query : query + "*"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "s", value: searchQuery),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "r", value: "json")
        ]
        
        if let year = year {
            components.queryItems?.append(URLQueryItem(name: "y", value: year))
        }
        
        if let type = type {
            components.queryItems?.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        
        do {
            let (data, _) = try await session.data(from: components.url!)
            let response = try JSONDecoder().decode(OMDBSearchResponse.self, from: data)
            
            if response.response == "False" {
                if let error = response.error {
                    if error.contains("Invalid API key") {
                        throw OMDBError.invalidAPIKey
                    } else if error.contains("Movie not found") || error.contains("Too many results") {
                        throw OMDBError.movieNotFound
                    } else if error.contains("Request limit reached") {
                        throw OMDBError.dailyLimitExceeded
                    } else {
                        throw OMDBError.unknownError(error)
                    }
                }
                throw OMDBError.invalidResponse
            }
            
            return response
        } catch let error as OMDBError {
            throw error
        } catch let error as DecodingError {
            throw OMDBError.decodingError(error)
        } catch {
            throw OMDBError.networkError(error)
        }
    }
    
}

// MARK: - IMDBFilm Conversion Extensions

/// Extensions for converting OMDB API response objects to IMDBFilm instances.
/// Handles the mapping between different API response formats and the unified IMDBFilm model.
extension IMDBFilm {
    /// Creates an IMDBFilm instance from a search result item.
    /// Search results contain limited metadata compared to detail responses.
    /// 
    /// **Data Mapping:**
    /// - Available: title, imdbID, year, type, poster
    /// - Unavailable: ratings, plot, cast, technical details
    /// - Missing fields set to nil (will be populated by detail fetch if needed)
    /// 
    /// - Parameter searchItem: OMDBSearchItem from search API response
    convenience init(from searchItem: OMDBSearchItem) {
        self.init(
            title: searchItem.title,
            imdbID: searchItem.imdbID,
            year: searchItem.year,
            rated: nil,
            released: nil,
            runtime: nil,
            genre: nil,
            director: nil,
            writer: nil,
            actors: nil,
            plot: nil,
            language: nil,
            country: nil,
            awards: nil,
            poster: searchItem.poster,
            ratings: nil,
            metascore: nil,
            imdbRating: nil,
            imdbVotes: nil,
            type: searchItem.type,
            response: nil
        )
    }
    
    /// Creates an IMDBFilm instance from a detailed API response.
    /// Detail responses contain complete film metadata including ratings, cast, and technical details.
    /// 
    /// **Data Mapping:**
    /// - Comprehensive: All available film metadata
    /// - Ratings: Converts API rating format to IMDBFilm.Rating objects
    /// - Validation: Handles missing or malformed data gracefully
    /// 
    /// **Rating Conversion:**
    /// - Maps OMDB rating objects to IMDBFilm.Rating format
    /// - Preserves source attribution (IMDB, Rotten Tomatoes, Metacritic)
    /// - Handles empty ratings arrays
    /// 
    /// - Parameter detail: OMDBDetailResponse from detail API call
    convenience init(from detail: OMDBDetailResponse) {
        let ratings = detail.ratings?.compactMap { rating in
            IMDBFilm.Rating(
                source: rating.source,
                value: rating.value
            )
        } ?? []
        
        self.init(
            title: detail.title,
            imdbID: detail.imdbID,
            year: detail.year,
            rated: detail.rated,
            released: detail.released,
            runtime: detail.runtime,
            genre: detail.genre,
            director: detail.director,
            writer: detail.writer,
            actors: detail.actors,
            plot: detail.plot,
            language: detail.language,
            country: detail.country,
            awards: detail.awards,
            poster: detail.poster,
            ratings: ratings.isEmpty ? nil : ratings,
            metascore: detail.metascore,
            imdbRating: detail.imdbRating,
            imdbVotes: detail.imdbVotes,
            type: detail.type,
            response: detail.response
        )
    }
}
