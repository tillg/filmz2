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
    
    // MARK: - Wide Search Tests
    
    func testWideSearch_PartialMatchAtStart() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Batman",
                    "Year": "1989",
                    "imdbID": "tt0096895",
                    "Type": "movie"
                },
                {
                    "Title": "Batman Begins",
                    "Year": "2005",
                    "imdbID": "tt0372784",
                    "Type": "movie"
                },
                {
                    "Title": "Batman Returns",
                    "Year": "1992",
                    "imdbID": "tt0103776",
                    "Type": "movie"
                }
            ],
            "totalResults": "3",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        // When searching for "bat", the service should add "*" automatically
        let result = try await sut.searchFilms(query: "bat")
        
        XCTAssertEqual(result.films.count, 3)
        XCTAssertTrue(result.films.allSatisfy { $0.title.lowercased().contains("bat") })
        XCTAssertTrue(result.films.contains(where: { $0.title == "Batman" }))
        XCTAssertTrue(result.films.contains(where: { $0.title == "Batman Begins" }))
        XCTAssertTrue(result.films.contains(where: { $0.title == "Batman Returns" }))
    }
    
    func testWideSearch_PartialMatchInMiddle() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Combat",
                    "Year": "2018",
                    "imdbID": "tt7580726",
                    "Type": "movie"
                },
                {
                    "Title": "Wombat",
                    "Year": "2024",
                    "imdbID": "tt30321794",
                    "Type": "movie"
                }
            ],
            "totalResults": "2",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result = try await sut.searchFilms(query: "bat")
        
        XCTAssertEqual(result.films.count, 2)
        XCTAssertTrue(result.films.allSatisfy { $0.title.lowercased().contains("bat") })
        XCTAssertTrue(result.films.contains(where: { $0.title == "Combat" }))
        XCTAssertTrue(result.films.contains(where: { $0.title == "Wombat" }))
    }
    
    func testWideSearch_PartialMatchAtEnd() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Acrobat",
                    "Year": "2020",
                    "imdbID": "tt11271038",
                    "Type": "movie"
                }
            ],
            "totalResults": "1",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result = try await sut.searchFilms(query: "bat")
        
        XCTAssertEqual(result.films.count, 1)
        XCTAssertEqual(result.films.first?.title, "Acrobat")
        XCTAssertTrue(result.films.first?.title.lowercased().contains("bat") ?? false)
    }
    
    func testWideSearch_CaseInsensitive() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Batman",
                    "Year": "1989",
                    "imdbID": "tt0096895",
                    "Type": "movie"
                },
                {
                    "Title": "BATMAN: The Movie",
                    "Year": "1966",
                    "imdbID": "tt0060153",
                    "Type": "movie"
                }
            ],
            "totalResults": "2",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result = try await sut.searchFilms(query: "BAT")
        
        XCTAssertEqual(result.films.count, 2)
        XCTAssertTrue(result.films.allSatisfy { $0.title.uppercased().contains("BAT") })
    }
    
    func testWideSearch_SpecialCharacters() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Mission: Impossible",
                    "Year": "1996",
                    "imdbID": "tt0117060",
                    "Type": "movie"
                },
                {
                    "Title": "Mission: Impossible II",
                    "Year": "2000",
                    "imdbID": "tt0120755",
                    "Type": "movie"
                }
            ],
            "totalResults": "2",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result = try await sut.searchFilms(query: "mission:")
        
        XCTAssertEqual(result.films.count, 2)
        XCTAssertTrue(result.films.allSatisfy { $0.title.contains("Mission:") })
    }
    
    func testWideSearch_NumericSearch() async throws {
        // Test that numeric searches work with wildcard
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "2001: A Space Odyssey",
                    "Year": "1968",
                    "imdbID": "tt0062622",
                    "Type": "movie"
                },
                {
                    "Title": "12 Angry Men",
                    "Year": "1957",
                    "imdbID": "tt0050083",
                    "Type": "movie"
                },
                {
                    "Title": "2 Fast 2 Furious",
                    "Year": "2003",
                    "imdbID": "tt0322259",
                    "Type": "movie"
                }
            ],
            "totalResults": "3",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        // Use wildcard to bypass minimum character requirement
        let result = try await sut.searchFilms(query: "2*")
        
        XCTAssertEqual(result.films.count, 3)
        XCTAssertTrue(result.films.allSatisfy { $0.title.contains("2") })
    }
    
    func testWideSearch_DoesNotDoubleWildcard() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Batman",
                    "Year": "1989",
                    "imdbID": "tt0096895",
                    "Type": "movie"
                }
            ],
            "totalResults": "1",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        // If user already added wildcard, don't add another
        let result = try await sut.searchFilms(query: "bat*")
        
        XCTAssertEqual(result.films.count, 1)
        XCTAssertEqual(result.films.first?.title, "Batman")
    }
    
    func testMinimumCharacterRequirement() async throws {
        // Test 1 character - should return empty
        let result1 = try await sut.searchFilms(query: "b")
        XCTAssertEqual(result1.films.count, 0)
        XCTAssertEqual(result1.totalResults, 0)
        
        // Test 2 characters - should return empty
        let result2 = try await sut.searchFilms(query: "ba")
        XCTAssertEqual(result2.films.count, 0)
        XCTAssertEqual(result2.totalResults, 0)
        
        // Test 3 characters - should work
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Batman",
                    "Year": "1989",
                    "imdbID": "tt0096895",
                    "Type": "movie"
                }
            ],
            "totalResults": "1",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        let result3 = try await sut.searchFilms(query: "bat")
        XCTAssertEqual(result3.films.count, 1)
    }
    
    func testMinimumCharacterRequirement_WithWildcard() async throws {
        let mockResponse = """
        {
            "Search": [
                {
                    "Title": "Batman",
                    "Year": "1989",
                    "imdbID": "tt0096895",
                    "Type": "movie"
                }
            ],
            "totalResults": "1",
            "Response": "True"
        }
        """
        mockSession.mockData = mockResponse.data(using: .utf8)
        
        // 2 characters with wildcard should work
        let result = try await sut.searchFilms(query: "ba*")
        XCTAssertEqual(result.films.count, 1)
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