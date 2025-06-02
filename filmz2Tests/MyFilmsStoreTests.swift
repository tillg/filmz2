//
//  MyFilmsStoreTests.swift
//  filmz2Tests
//
//  Created by Till Gartner on 06.01.25.
//

import XCTest
import SwiftData
@testable import filmz2

@MainActor
class MyFilmsStoreTests: XCTestCase {
    var sut: MyFilmsStore!
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container for testing
        let schema = Schema([MyFilm.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
        
        // Create store
        sut = MyFilmsStore(modelContext: modelContext)
    }
    
    override func tearDown() {
        sut = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }
    
    // MARK: - Add Film Tests
    
    func testAddFilmFromSearchItem_Success() async throws {
        let searchItem = OMDBSearchItem(
            title: "The Matrix",
            year: "1999",
            imdbID: "tt0133093",
            type: "movie",
            poster: "https://example.com/poster.jpg"
        )
        
        let film = try await sut.addFilm(from: searchItem)
        
        XCTAssertEqual(film.title, "The Matrix")
        XCTAssertEqual(film.imdbID, "tt0133093")
        XCTAssertEqual(film.year, "1999")
        XCTAssertFalse(film.watched)
        
        // Verify film is in collection
        let isInCollection = sut.isFilmInCollection("tt0133093")
        XCTAssertTrue(isInCollection)
    }
    
    func testAddFilmFromSearchItem_AlreadyExists() async throws {
        let searchItem = OMDBSearchItem(
            title: "The Matrix",
            year: "1999",
            imdbID: "tt0133093",
            type: "movie",
            poster: nil
        )
        
        // Add film first time
        _ = try await sut.addFilm(from: searchItem)
        
        // Try to add again
        do {
            _ = try await sut.addFilm(from: searchItem)
            XCTFail("Expected error but got success")
        } catch let error as MyFilmsStoreError {
            if case .filmAlreadyExists(let title) = error {
                XCTAssertEqual(title, "The Matrix")
            } else {
                XCTFail("Wrong error type")
            }
        }
    }
    
    func testAddFilmFromIMDBFilm_Success() async throws {
        let imdbFilm = IMDBFilm.darkKnight
        
        let film = try await sut.addFilm(from: imdbFilm)
        
        XCTAssertEqual(film.title, imdbFilm.title)
        XCTAssertEqual(film.imdbID, imdbFilm.imdbID)
        XCTAssertEqual(film.genres, imdbFilm.genreList)
        XCTAssertEqual(film.director, imdbFilm.director)
        XCTAssertEqual(film.plot, imdbFilm.plot)
    }
    
    // MARK: - Query Tests
    
    func testGetFilmByID() async throws {
        let searchItem = OMDBSearchItem(
            title: "Inception",
            year: "2010",
            imdbID: "tt1375666",
            type: "movie",
            poster: nil
        )
        
        _ = try await sut.addFilm(from: searchItem)
        
        let retrievedFilm = try sut.getFilm(by: "tt1375666")
        
        XCTAssertNotNil(retrievedFilm)
        XCTAssertEqual(retrievedFilm?.title, "Inception")
    }
    
    func testIsFilmInCollection() async throws {
        let searchItem = OMDBSearchItem(
            title: "The Dark Knight",
            year: "2008",
            imdbID: "tt0468569",
            type: "movie",
            poster: nil
        )
        
        // Check before adding
        let beforeAdding = sut.isFilmInCollection("tt0468569")
        XCTAssertFalse(beforeAdding)
        
        // Add film
        _ = try await sut.addFilm(from: searchItem)
        
        // Check after adding
        let afterAdding = sut.isFilmInCollection("tt0468569")
        XCTAssertTrue(afterAdding)
    }
    
    // MARK: - Update Tests
    
    func testMarkAsWatched() async throws {
        let searchItem = OMDBSearchItem(
            title: "Test Movie",
            year: "2024",
            imdbID: "tt9999999",
            type: "movie",
            poster: nil
        )
        
        let film = try await sut.addFilm(from: searchItem)
        
        XCTAssertFalse(film.watched)
        XCTAssertNil(film.dateWatched)
        
        let watchDate = Date()
        try sut.markAsWatched(film, date: watchDate)
        
        XCTAssertTrue(film.watched)
        XCTAssertNotNil(film.dateWatched)
    }
    
    func testRateFilm() async throws {
        let searchItem = OMDBSearchItem(
            title: "Test Movie",
            year: "2024",
            imdbID: "tt8888888",
            type: "movie",
            poster: nil
        )
        
        let film = try await sut.addFilm(from: searchItem)
        
        XCTAssertNil(film.myRating)
        
        try sut.rateFilm(film, rating: 8)
        
        XCTAssertEqual(film.myRating, 8)
    }
    
    func testRateFilm_InvalidRating() async throws {
        let searchItem = OMDBSearchItem(
            title: "Test Movie",
            year: "2024",
            imdbID: "tt7777777",
            type: "movie",
            poster: nil
        )
        
        let film = try await sut.addFilm(from: searchItem)
        
        do {
            try sut.rateFilm(film, rating: 11)
            XCTFail("Expected error for invalid rating")
        } catch let error as MyFilmsStoreError {
            XCTAssertEqual(error, .invalidRating)
        }
    }
    
    // MARK: - Delete Tests
    
    func testDeleteFilm() async throws {
        let searchItem = OMDBSearchItem(
            title: "To Delete",
            year: "2024",
            imdbID: "tt6666666",
            type: "movie",
            poster: nil
        )
        
        let film = try await sut.addFilm(from: searchItem)
        
        let beforeDelete = sut.isFilmInCollection("tt6666666")
        XCTAssertTrue(beforeDelete)
        
        try sut.deleteFilm(film)
        
        let afterDelete = sut.isFilmInCollection("tt6666666")
        XCTAssertFalse(afterDelete)
    }
    
    // MARK: - Filter Tests
    
    func testGetWatchedFilms() async throws {
        // Add watched film
        let watchedItem = OMDBSearchItem(
            title: "Watched Movie",
            year: "2024",
            imdbID: "tt1111111",
            type: "movie",
            poster: nil
        )
        let watchedFilm = try await sut.addFilm(from: watchedItem)
        try sut.markAsWatched(watchedFilm)
        
        // Add unwatched film
        let unwatchedItem = OMDBSearchItem(
            title: "Unwatched Movie",
            year: "2024",
            imdbID: "tt2222222",
            type: "movie",
            poster: nil
        )
        _ = try await sut.addFilm(from: unwatchedItem)
        
        let watchedFilms = try sut.getWatchedFilms()
        
        XCTAssertEqual(watchedFilms.count, 1)
        XCTAssertEqual(watchedFilms.first?.title, "Watched Movie")
    }
    
    func testGetUnwatchedFilms() async throws {
        // Add watched film
        let watchedItem = OMDBSearchItem(
            title: "Watched Movie",
            year: "2024",
            imdbID: "tt3333333",
            type: "movie",
            poster: nil
        )
        let watchedFilm = try await sut.addFilm(from: watchedItem)
        try sut.markAsWatched(watchedFilm)
        
        // Add unwatched film
        let unwatchedItem = OMDBSearchItem(
            title: "Unwatched Movie",
            year: "2024",
            imdbID: "tt4444444",
            type: "movie",
            poster: nil
        )
        _ = try await sut.addFilm(from: unwatchedItem)
        
        let unwatchedFilms = try sut.getUnwatchedFilms()
        
        XCTAssertEqual(unwatchedFilms.count, 1)
        XCTAssertEqual(unwatchedFilms.first?.title, "Unwatched Movie")
    }
    
    // MARK: - Statistics Tests
    
    func testFilmCounts() async throws {
        XCTAssertEqual(sut.totalFilmsCount, 0)
        
        // Add films
        let items = [
            OMDBSearchItem(title: "Film 1", year: "2024", imdbID: "tt0000001", type: "movie", poster: nil),
            OMDBSearchItem(title: "Film 2", year: "2024", imdbID: "tt0000002", type: "movie", poster: nil),
            OMDBSearchItem(title: "Film 3", year: "2024", imdbID: "tt0000003", type: "movie", poster: nil)
        ]
        
        for item in items {
            _ = try await sut.addFilm(from: item)
        }
        
        XCTAssertEqual(sut.totalFilmsCount, 3)
        XCTAssertEqual(sut.watchedFilmsCount, 0)
        XCTAssertEqual(sut.unwatchedFilmsCount, 3)
        
        // Mark one as watched
        if let firstFilm = sut.films.first {
            try sut.markAsWatched(firstFilm)
        }
        
        XCTAssertEqual(sut.watchedFilmsCount, 1)
        XCTAssertEqual(sut.unwatchedFilmsCount, 2)
    }
}

// Make error equatable for testing
extension MyFilmsStoreError: Equatable {
    public static func == (lhs: MyFilmsStoreError, rhs: MyFilmsStoreError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRating, .invalidRating):
            return true
        case (.filmAlreadyExists(let lhsTitle), .filmAlreadyExists(let rhsTitle)):
            return lhsTitle == rhsTitle
        case (.saveFailed, .saveFailed),
             (.deleteFailed, .deleteFailed):
            return true
        default:
            return false
        }
    }
}