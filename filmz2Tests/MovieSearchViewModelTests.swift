import XCTest
import Combine
@testable import filmz2

class MockOMDBSearchService: OMDBSearchServiceProtocol {
    var searchFilmsResult: Result<SearchResult, Error>?
    var searchFilmsRawResult: Result<OMDBSearchResponse, Error>?
    var getFilmResult: Result<IMDBFilm, Error>?
    
    var searchFilmsCallCount = 0
    var searchFilmsRawCallCount = 0
    var getFilmByIDCallCount = 0
    var getFilmByTitleCallCount = 0
    
    var lastSearchQuery: String?
    var lastSearchPage: Int?
    
    func searchFilms(query: String, year: String?, type: MediaType?, page: Int) async throws -> SearchResult {
        searchFilmsCallCount += 1
        lastSearchQuery = query
        lastSearchPage = page
        
        if let result = searchFilmsResult {
            switch result {
            case .success(let searchResult):
                return searchResult
            case .failure(let error):
                throw error
            }
        }
        throw OMDBError.unknownError("No mock result configured")
    }
    
    func searchFilmsRaw(query: String, year: String?, type: MediaType?, page: Int) async throws -> OMDBSearchResponse {
        searchFilmsRawCallCount += 1
        lastSearchQuery = query
        lastSearchPage = page
        
        if let result = searchFilmsRawResult {
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
        throw OMDBError.unknownError("No mock result configured")
    }
    
    func getFilm(byID: String) async throws -> IMDBFilm {
        getFilmByIDCallCount += 1
        
        if let result = getFilmResult {
            switch result {
            case .success(let film):
                return film
            case .failure(let error):
                throw error
            }
        }
        throw OMDBError.unknownError("No mock result configured")
    }
    
    func getFilm(byTitle: String, year: String?) async throws -> IMDBFilm {
        getFilmByTitleCallCount += 1
        
        if let result = getFilmResult {
            switch result {
            case .success(let film):
                return film
            case .failure(let error):
                throw error
            }
        }
        throw OMDBError.unknownError("No mock result configured")
    }
    
}

@MainActor
class MovieSearchViewModelTests: XCTestCase {
    var viewModel: MovieSearchViewModel!
    var mockService: MockOMDBSearchService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockOMDBSearchService()
        viewModel = MovieSearchViewModel(searchService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.searchQuery, "")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.hasSearched)
    }
    
    func testSearchDebouncing() async throws {
        // Configure mock response
        let mockResults = [
            OMDBSearchItem(title: "Batman", year: "1989", imdbID: "tt0096895", type: "movie", poster: nil),
            OMDBSearchItem(title: "Batman Returns", year: "1992", imdbID: "tt0103776", type: "movie", poster: nil)
        ]
        let mockResponse = OMDBSearchResponse(
            search: mockResults,
            totalResults: "2",
            response: "True",
            error: nil
        )
        mockService.searchFilmsRawResult = .success(mockResponse)
        
        // Type rapidly
        viewModel.searchQuery = "B"
        viewModel.searchQuery = "Ba"
        viewModel.searchQuery = "Bat"
        viewModel.searchQuery = "Batm"
        viewModel.searchQuery = "Batma"
        viewModel.searchQuery = "Batman"
        
        // Wait less than debounce time
        try await Task.sleep(nanoseconds: 300_000_000) // 300ms
        
        // Should not have made any calls yet
        XCTAssertEqual(mockService.searchFilmsRawCallCount, 0)
        
        // Wait for debounce to complete
        try await Task.sleep(nanoseconds: 300_000_000) // Another 300ms
        
        // Should have made exactly one call
        XCTAssertEqual(mockService.searchFilmsRawCallCount, 1)
        XCTAssertEqual(mockService.lastSearchQuery, "Batman")
        XCTAssertEqual(viewModel.searchResults.count, 2)
    }
    
    func testSuccessfulSearch() async throws {
        // Configure mock response
        let mockResults = [
            OMDBSearchItem(title: "The Dark Knight", year: "2008", imdbID: "tt0468569", type: "movie", poster: "https://example.com/poster.jpg")
        ]
        let mockResponse = OMDBSearchResponse(
            search: mockResults,
            totalResults: "1",
            response: "True",
            error: nil
        )
        mockService.searchFilmsRawResult = .success(mockResponse)
        
        // Trigger search
        viewModel.searchQuery = "Dark Knight"
        
        // Wait for debounce and async operation
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        // Verify results
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.title, "The Dark Knight")
        XCTAssertTrue(viewModel.hasSearched)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testEmptySearchResults() async throws {
        // Configure mock response with no results
        let mockResponse = OMDBSearchResponse(
            search: nil,
            totalResults: "0",
            response: "False",
            error: "Movie not found!"
        )
        mockService.searchFilmsRawResult = .failure(OMDBError.movieNotFound)
        
        // Trigger search
        viewModel.searchQuery = "NonexistentMovie"
        
        // Wait for debounce and async operation
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        // Verify empty state
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertTrue(viewModel.hasSearched)
        XCTAssertNil(viewModel.errorMessage) // Movie not found is handled as empty state
    }
    
    func testNetworkError() async throws {
        // Configure mock to return network error
        mockService.searchFilmsRawResult = .failure(OMDBError.networkError(URLError(.notConnectedToInternet)))
        
        // Trigger search
        viewModel.searchQuery = "Batman"
        
        // Wait for debounce and async operation
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        // Verify error state
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Network error") ?? false)
    }
    
    func testAPIKeyError() async throws {
        // Configure mock to return API key error
        mockService.searchFilmsRawResult = .failure(OMDBError.invalidAPIKey)
        
        // Trigger search
        viewModel.searchQuery = "Batman"
        
        // Wait for debounce and async operation
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        // Verify error state
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Invalid API key") ?? false)
    }
    
    func testDailyLimitError() async throws {
        // Configure mock to return daily limit error
        mockService.searchFilmsRawResult = .failure(OMDBError.dailyLimitExceeded)
        
        // Trigger search
        viewModel.searchQuery = "Batman"
        
        // Wait for debounce and async operation
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        // Verify error state
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Daily API limit exceeded") ?? false)
    }
    
    func testClearingSearch() async throws {
        // First perform a search
        let mockResults = [
            OMDBSearchItem(title: "Batman", year: "1989", imdbID: "tt0096895", type: "movie", poster: nil)
        ]
        let mockResponse = OMDBSearchResponse(
            search: mockResults,
            totalResults: "1",
            response: "True",
            error: nil
        )
        mockService.searchFilmsRawResult = .success(mockResponse)
        
        viewModel.searchQuery = "Batman"
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        XCTAssertEqual(viewModel.searchResults.count, 1)
        
        // Clear search
        viewModel.searchQuery = ""
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        // Verify cleared state
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.hasSearched)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSelectFilm() async throws {
        // Configure mock film details
        let mockFilm = IMDBFilm.darkKnight
        mockService.getFilmResult = .success(mockFilm)
        
        // Create search result
        let searchItem = OMDBSearchItem(
            title: "The Dark Knight",
            year: "2008",
            imdbID: "tt0468569",
            type: "movie",
            poster: nil
        )
        
        // Select film
        let selectedFilm = await viewModel.selectFilm(searchItem)
        
        // Verify
        XCTAssertNotNil(selectedFilm)
        XCTAssertEqual(selectedFilm?.imdbID, mockFilm.imdbID)
        XCTAssertEqual(mockService.getFilmByIDCallCount, 1)
    }
    
    func testSelectFilmError() async throws {
        // Configure mock to return error
        mockService.getFilmResult = .failure(OMDBError.networkError(URLError(.timedOut)))
        
        // Create search result
        let searchItem = OMDBSearchItem(
            title: "The Dark Knight",
            year: "2008",
            imdbID: "tt0468569",
            type: "movie",
            poster: nil
        )
        
        // Select film
        let selectedFilm = await viewModel.selectFilm(searchItem)
        
        // Verify
        XCTAssertNil(selectedFilm)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("Failed to load movie details") ?? false)
    }
    
    func testPagination() async throws {
        // Configure mock response for first page
        let firstPageResults = (1...10).map { i in
            OMDBSearchItem(
                title: "Batman Movie \(i)",
                year: "200\(i)",
                imdbID: "tt\(i)",
                type: "movie",
                poster: nil
            )
        }
        let firstPageResponse = OMDBSearchResponse(
            search: firstPageResults,
            totalResults: "25",
            response: "True",
            error: nil
        )
        mockService.searchFilmsRawResult = .success(firstPageResponse)
        
        // Trigger search
        viewModel.searchQuery = "Batman"
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        XCTAssertEqual(viewModel.searchResults.count, 10)
        XCTAssertEqual(mockService.lastSearchPage, 1)
        
        // Configure mock response for second page
        let secondPageResults = (11...20).map { i in
            OMDBSearchItem(
                title: "Batman Movie \(i)",
                year: "20\(i)",
                imdbID: "tt\(i)",
                type: "movie",
                poster: nil
            )
        }
        let secondPageResponse = OMDBSearchResponse(
            search: secondPageResults,
            totalResults: "25",
            response: "True",
            error: nil
        )
        mockService.searchFilmsRawResult = .success(secondPageResponse)
        
        // Trigger pagination
        viewModel.loadMoreIfNeeded(currentItem: firstPageResults.last)
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Verify pagination
        XCTAssertEqual(viewModel.searchResults.count, 20)
        XCTAssertEqual(mockService.lastSearchPage, 2)
        XCTAssertEqual(mockService.searchFilmsRawCallCount, 2)
    }
    
    func testRetry() async throws {
        // First configure error
        mockService.searchFilmsRawResult = .failure(OMDBError.networkError(URLError(.timedOut)))
        
        viewModel.searchQuery = "Batman"
        try await Task.sleep(nanoseconds: 700_000_000) // 700ms
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(mockService.searchFilmsRawCallCount, 1)
        
        // Configure success for retry
        let mockResults = [
            OMDBSearchItem(title: "Batman", year: "1989", imdbID: "tt0096895", type: "movie", poster: nil)
        ]
        let mockResponse = OMDBSearchResponse(
            search: mockResults,
            totalResults: "1",
            response: "True",
            error: nil
        )
        mockService.searchFilmsRawResult = .success(mockResponse)
        
        // Retry
        viewModel.retry()
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Verify retry succeeded
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockService.searchFilmsRawCallCount, 2)
    }
}