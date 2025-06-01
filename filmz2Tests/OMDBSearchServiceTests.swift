import XCTest
@testable import filmz2

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (mockData ?? Data(), response)
    }
}

class OMDBSearchServiceTests: XCTestCase {
    var sut: OMDBSearchService!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        sut = OMDBSearchService(apiKey: "test-api-key", session: mockSession)
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testSearchFilms_Success() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "The Matrix",
                    "Year": "1999",
                    "imdbID": "tt0133093",
                    "Type": "movie",
                    "Poster": "https://example.com/poster.jpg"
                }
            ],
            "totalResults": "1",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result = try await sut.searchFilms(query: "Matrix")
        
        XCTAssertEqual(result.films.count, 1)
        XCTAssertEqual(result.films.first?.title, "The Matrix")
        XCTAssertEqual(result.films.first?.year, "1999")
        XCTAssertEqual(result.totalResults, 1)
        XCTAssertEqual(result.currentPage, 1)
    }
    
    func testSearchFilms_WithPagination() async throws {
        let mockResponse = """
        {
            "Search": [],
            "totalResults": "25",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result = try await sut.searchFilms(query: "Batman", page: 2)
        
        XCTAssertEqual(result.currentPage, 2)
        XCTAssertEqual(result.totalPages, 3)
    }
    
    func testSearchFilms_MovieNotFound() async throws {
        let mockResponse = """
        {
            "Response": "False",
            "Error": "Movie not found!"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        do {
            _ = try await sut.searchFilms(query: "NonExistentMovie")
            XCTFail("Expected error but got success")
        } catch let error as OMDBError {
            XCTAssertEqual(error, .movieNotFound)
        }
    }
    
    func testSearchFilms_InvalidAPIKey() async throws {
        let mockResponse = """
        {
            "Response": "False",
            "Error": "Invalid API key!"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        do {
            _ = try await sut.searchFilms(query: "Matrix")
            XCTFail("Expected error but got success")
        } catch let error as OMDBError {
            XCTAssertEqual(error, .invalidAPIKey)
        }
    }
    
    func testGetFilmByID_Success() async throws {
        let mockResponse = """
        {
            "Title": "The Matrix",
            "Year": "1999",
            "Rated": "R",
            "Released": "31 Mar 1999",
            "Runtime": "136 min",
            "Genre": "Action, Sci-Fi",
            "Director": "Lana Wachowski, Lilly Wachowski",
            "Plot": "A computer programmer discovers...",
            "Poster": "https://example.com/poster.jpg",
            "imdbRating": "8.7",
            "imdbID": "tt0133093",
            "Type": "movie",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let film = try await sut.getFilm(byID: "tt0133093")
        
        XCTAssertEqual(film.title, "The Matrix")
        XCTAssertEqual(film.year, "1999")
        XCTAssertEqual(film.imdbID, "tt0133093")
        XCTAssertEqual(film.rated, "R")
        XCTAssertEqual(film.imdbRating, "8.7")
    }
    
    func testGetFilmByTitle_Success() async throws {
        let mockResponse = """
        {
            "Title": "The Matrix",
            "Year": "1999",
            "imdbID": "tt0133093",
            "Type": "movie",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let film = try await sut.getFilm(byTitle: "The Matrix", year: "1999")
        
        XCTAssertEqual(film.title, "The Matrix")
        XCTAssertEqual(film.year, "1999")
    }
    
    func testCaching() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "The Matrix",
                    "Year": "1999",
                    "imdbID": "tt0133093",
                    "Type": "movie"
                }
            ],
            "totalResults": "1",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result1 = try await sut.searchFilms(query: "Matrix")
        
        mockSession.mockData = nil
        mockSession.mockError = URLError(.notConnectedToInternet)
        
        let result2 = try await sut.searchFilms(query: "Matrix")
        
        XCTAssertEqual(result1.films.count, result2.films.count)
        XCTAssertEqual(result1.films.first?.title, result2.films.first?.title)
    }
    
    func testNetworkError() async throws {
        mockSession.mockError = URLError(.notConnectedToInternet)
        
        do {
            _ = try await sut.searchFilms(query: "Matrix")
            XCTFail("Expected error but got success")
        } catch let error as OMDBError {
            if case .networkError = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Expected network error")
            }
        }
    }
}

extension OMDBError: Equatable {
    public static func == (lhs: OMDBError, rhs: OMDBError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidAPIKey, .invalidAPIKey),
             (.movieNotFound, .movieNotFound),
             (.invalidResponse, .invalidResponse):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        default:
            return false
        }
    }
}