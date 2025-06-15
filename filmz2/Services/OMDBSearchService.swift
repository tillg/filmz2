import Foundation
import SwiftData

protocol OMDBSearchServiceProtocol {
    func searchFilms(query: String, year: String?, type: MediaType?, page: Int) async throws -> SearchResult
    func searchFilmsRaw(query: String, year: String?, type: MediaType?, page: Int) async throws -> OMDBSearchResponse
    func getFilm(byID: String) async throws -> IMDBFilm
    func getFilm(byTitle: String, year: String?) async throws -> IMDBFilm
    func getFilmDetails(imdbID: String) async throws -> IMDBFilm
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

enum OMDBError: Error, LocalizedError {
    case invalidAPIKey
    case movieNotFound
    case invalidResponse
    case networkError(Error)
    case dailyLimitExceeded
    case decodingError(Error)
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

class OMDBSearchService: OMDBSearchServiceProtocol {
    static let shared = OMDBSearchService(apiKey: APIKeys.omdbAPIKey)
    
    private let apiKey: String
    private let baseURL = "https://www.omdbapi.com/"
    private let session: URLSessionProtocol
    private var cache: [String: Any] = [:]
    
    init(apiKey: String, session: URLSessionProtocol = URLSession.shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    func setModelContext(_ context: ModelContext) {
        // No longer needed - using CacheManager
        print("OMDBSearchService: Model context set (deprecated)")
    }
    
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
    
    func getFilm(byID: String) async throws -> IMDBFilm {
        // First check persistent cache
        if let cachedFilm = await CacheManager.shared.fetchFilm(imdbID: byID) {
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
            
            // Save to persistent cache using CacheManager
            await CacheManager.shared.saveFilm(film)
            
            return film
            
        } catch let error as OMDBError {
            throw error
        } catch {
            throw OMDBError.networkError(error)
        }
    }
    
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
    
    func getFilmDetails(imdbID: String) async throws -> IMDBFilm {
        return try await getFilm(byID: imdbID)
    }
}

extension IMDBFilm {
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