import Foundation

/// Factory for creating OMDB search service instances
/// Allows dependency injection for testing while keeping production code clean
struct OMDBServiceFactory {
    
    /// Creates the appropriate search service based on runtime environment
    static func createSearchService() -> OMDBSearchServiceProtocol {
        // Check if we're in UI testing mode
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            // Use a simple mock implementation for UI tests
            return MockOMDBServiceForTesting()
        } else {
            // Use the real service for production
            return OMDBSearchService.shared
        }
    }
}

/// Minimal mock service implementation for UI testing
/// This is a simplified version that provides instant responses
private class MockOMDBServiceForTesting: OMDBSearchServiceProtocol {
    
    func searchFilms(query: String, year: String? = nil, type: MediaType? = nil, page: Int = 1) async throws -> SearchResult {
        // Simulate brief delay for realistic UI behavior
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Handle minimum character requirement
        guard query.count >= 3 || query.contains("*") else {
            return SearchResult(films: [], totalResults: 0, currentPage: page, totalPages: 0)
        }
        
        // Handle the nonsense query that should return empty results
        if query == "xyzabc123456789" {
            return SearchResult(films: [], totalResults: 0, currentPage: page, totalPages: 0)
        }
        
        // Return mock results based on query
        let mockSearchItems = createMockResults(for: query.lowercased())
        
        // Convert OMDBSearchItems to IMDBFilms
        let mockFilms = mockSearchItems.compactMap { item in
            IMDBFilm(from: item)
        }
        
        // Simulate pagination
        let startIndex = (page - 1) * 10
        let endIndex = min(startIndex + 10, mockFilms.count)
        let pageResults = startIndex < mockFilms.count ? Array(mockFilms[startIndex..<endIndex]) : []
        
        let totalPages = (mockFilms.count + 9) / 10
        
        return SearchResult(
            films: pageResults,
            totalResults: mockFilms.count,
            currentPage: page,
            totalPages: totalPages
        )
    }
    
    func searchFilmsRaw(query: String, year: String? = nil, type: MediaType? = nil, page: Int = 1) async throws -> OMDBSearchResponse {
        let result = try await searchFilms(query: query, year: year, type: type, page: page)
        
        // Convert IMDBFilms back to OMDBSearchItems for raw API compatibility
        let searchItems = result.films.map { film in
            OMDBSearchItem(
                title: film.title,
                year: film.year ?? "",
                imdbID: film.imdbID,
                type: film.type ?? "movie",
                poster: film.poster
            )
        }
        
        return OMDBSearchResponse(
            search: searchItems,
            totalResults: "\(result.totalResults)",
            response: result.totalResults > 0 ? "True" : "False",
            error: result.totalResults == 0 ? "Movie not found!" : nil
        )
    }
    
    func getFilm(byID imdbID: String) async throws -> IMDBFilm {
        // Simulate brief delay
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Return a mock film based on ID
        switch imdbID {
        case "tt0372784":
            return createMockBatmanBegins()
        case "tt1877830":
            return createMockTheBatman()
        case "tt1375666":
            return createMockInception()
        default:
            throw OMDBError.movieNotFound
        }
    }
    
    func getFilm(byTitle title: String, year: String? = nil) async throws -> IMDBFilm {
        // Simulate brief delay
        try await Task.sleep(nanoseconds: 100_000_000)
        
        // Simple title matching for common test cases
        switch title.lowercased() {
        case "batman begins":
            return createMockBatmanBegins()
        case "the batman":
            return createMockTheBatman()
        case "inception":
            return createMockInception()
        default:
            throw OMDBError.movieNotFound
        }
    }
    
    // MARK: - Mock Data Creation
    
    private func createMockResults(for query: String) -> [OMDBSearchItem] {
        switch query {
        case "batman":
            return [
                OMDBSearchItem(title: "Batman Begins", year: "2005", imdbID: "tt0372784", type: "movie", poster: "https://example.com/batman-begins.jpg"),
                OMDBSearchItem(title: "The Batman", year: "2022", imdbID: "tt1877830", type: "movie", poster: "https://example.com/the-batman.jpg"),
                OMDBSearchItem(title: "Batman v Superman: Dawn of Justice", year: "2016", imdbID: "tt2975590", type: "movie", poster: "https://example.com/bvs.jpg"),
                OMDBSearchItem(title: "Batman", year: "1989", imdbID: "tt0096895", type: "movie", poster: "https://example.com/batman.jpg"),
                OMDBSearchItem(title: "Batman Returns", year: "1992", imdbID: "tt0103776", type: "movie", poster: "https://example.com/batman-returns.jpg")
            ]
        case "bat":
            return [
                OMDBSearchItem(title: "Batman", year: "1989", imdbID: "tt0096895", type: "movie", poster: "https://example.com/batman.jpg"),
                OMDBSearchItem(title: "Batman Begins", year: "2005", imdbID: "tt0372784", type: "movie", poster: "https://example.com/batman-begins.jpg"),
                OMDBSearchItem(title: "Combat", year: "2018", imdbID: "tt7580726", type: "movie", poster: "https://example.com/combat.jpg"),
                OMDBSearchItem(title: "Wombat", year: "2024", imdbID: "tt30321794", type: "movie", poster: "https://example.com/wombat.jpg"),
                OMDBSearchItem(title: "Acrobat", year: "2020", imdbID: "tt11271038", type: "movie", poster: "https://example.com/acrobat.jpg")
            ]
        case "star wars":
            return [
                OMDBSearchItem(title: "Star Wars", year: "1977", imdbID: "tt0076759", type: "movie", poster: "https://example.com/star-wars.jpg"),
                OMDBSearchItem(title: "Star Wars: The Empire Strikes Back", year: "1980", imdbID: "tt0080684", type: "movie", poster: "https://example.com/empire.jpg"),
                OMDBSearchItem(title: "Star Wars: Return of the Jedi", year: "1983", imdbID: "tt0086190", type: "movie", poster: "https://example.com/return-jedi.jpg")
            ]
        case "inception":
            return [
                OMDBSearchItem(title: "Inception", year: "2010", imdbID: "tt1375666", type: "movie", poster: "https://example.com/inception.jpg")
            ]
        case "mission:":
            return [
                OMDBSearchItem(title: "Mission: Impossible", year: "1996", imdbID: "tt0117060", type: "movie", poster: "https://example.com/mission-impossible.jpg"),
                OMDBSearchItem(title: "Mission: Impossible II", year: "2000", imdbID: "tt0120755", type: "movie", poster: "https://example.com/mission-impossible-2.jpg")
            ]
        default:
            return []
        }
    }
    
    private func createMockBatmanBegins() -> IMDBFilm {
        return IMDBFilm(
            title: "Batman Begins",
            imdbID: "tt0372784",
            year: "2005",
            rated: "PG-13",
            released: "15 Jun 2005",
            runtime: "140 min",
            genre: "Action, Crime, Drama",
            director: "Christopher Nolan",
            writer: "Bob Kane, David S. Goyer, Christopher Nolan",
            actors: "Christian Bale, Michael Caine, Liam Neeson",
            plot: "After witnessing his parents' death, Bruce Wayne learns the art of fighting to confront injustice.",
            language: "English",
            country: "USA, UK",
            awards: "Nominated for 1 Oscar",
            poster: "https://example.com/batman-begins.jpg",
            ratings: [],
            metascore: "70",
            imdbRating: "8.2",
            imdbVotes: "1,400,000",
            type: "movie",
            response: "True"
        )
    }
    
    private func createMockTheBatman() -> IMDBFilm {
        return IMDBFilm(
            title: "The Batman",
            imdbID: "tt1877830",
            year: "2022",
            rated: "PG-13",
            released: "04 Mar 2022",
            runtime: "176 min",
            genre: "Action, Crime, Drama",
            director: "Matt Reeves",
            writer: "Matt Reeves, Peter Craig, Bob Kane",
            actors: "Robert Pattinson, Zoë Kravitz, Jeffrey Wright",
            plot: "When a killer targets Gotham's elite with a series of sadistic machinations, a trail of cryptic clues sends the World's Greatest Detective on an investigation into the underworld.",
            language: "English",
            country: "United States",
            awards: "7 wins & 65 nominations",
            poster: "https://example.com/the-batman.jpg",
            ratings: [],
            metascore: "72",
            imdbRating: "7.8",
            imdbVotes: "721,089",
            type: "movie",
            response: "True"
        )
    }
    
    private func createMockInception() -> IMDBFilm {
        return IMDBFilm(
            title: "Inception",
            imdbID: "tt1375666",
            year: "2010",
            rated: "PG-13",
            released: "16 Jul 2010",
            runtime: "148 min",
            genre: "Action, Adventure, Sci-Fi",
            director: "Christopher Nolan",
            writer: "Christopher Nolan",
            actors: "Leonardo DiCaprio, Marion Cotillard, Tom Hardy",
            plot: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
            language: "English, Japanese, French",
            country: "United States, United Kingdom",
            awards: "Won 4 Oscars. 157 wins & 220 nominations total",
            poster: "https://example.com/inception.jpg",
            ratings: [],
            metascore: "74",
            imdbRating: "8.8",
            imdbVotes: "2,400,000",
            type: "movie",
            response: "True"
        )
    }
}