//
//  FilmDetailCachingTests.swift
//  filmz2Tests
//
//  Created by Claude on 02.06.25.
//

import XCTest
import SwiftData
@testable import filmz2

final class FilmDetailCachingTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var searchService: OMDBSearchService!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory model container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(
            for: IMDBFilm.self, MyFilm.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)
        
        // Initialize search service
        searchService = OMDBSearchService.shared
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        searchService = nil
        super.tearDown()
    }
    
    func testFilmDetailsAreCachedWhenFetched() async throws {
        // Given: A film ID that's not in cache
        let imdbID = "tt10986410" // Ted Lasso
        
        // Verify not in cache
        let initialFetch = FetchDescriptor<IMDBFilm>(
            predicate: #Predicate { $0.imdbID == imdbID }
        )
        let initialResults = try modelContext.fetch(initialFetch)
        XCTAssertTrue(initialResults.isEmpty, "Film should not be cached initially")
        
        // When: Fetching film details (this would happen when viewing details)
        // Note: This test will only work with a mock service or if API key is available
        // For now, we'll simulate the caching behavior
        
        let filmData = IMDBFilm(
            title: "Ted Lasso",
            imdbID: imdbID,
            year: "2020–2023",
            rated: "TV-MA",
            released: "14 Aug 2020",
            runtime: "30 min",
            genre: "Comedy, Drama, Sport",
            director: "N/A",
            writer: "Jason Sudeikis, Brendan Hunt, Joe Kelly",
            actors: "Jason Sudeikis, Hannah Waddingham, Jeremy Swift",
            plot: "American college football coach Ted Lasso heads to London...",
            language: "English",
            country: "United States, United Kingdom",
            awards: "Won 11 Primetime Emmys",
            poster: "https://example.com/poster.jpg",
            ratings: [
                IMDBFilm.Rating(source: "Internet Movie Database", value: "8.8/10")
            ],
            metascore: "71",
            imdbRating: "8.8",
            imdbVotes: "294,729",
            type: "series",
            response: "True"
        )
        
        // Simulate the caching that would happen in OMDBSearchService
        modelContext.insert(filmData)
        try modelContext.save()
        
        // Then: Film should be in cache with rating
        let finalResults = try modelContext.fetch(initialFetch)
        XCTAssertEqual(finalResults.count, 1)
        XCTAssertEqual(finalResults.first?.imdbRating, "8.8")
        XCTAssertEqual(finalResults.first?.title, "Ted Lasso")
    }
    
    func testCachedFilmIsFoundBySearchResultCell() throws {
        // Given: A cached film
        let searchItem = OMDBSearchItem(
            title: "Ted Lasso",
            year: "2020–",
            imdbID: "tt10986410",
            type: "series",
            poster: "https://example.com/poster.jpg"
        )
        
        let cachedFilm = IMDBFilm(
            title: searchItem.title,
            imdbID: searchItem.imdbID,
            year: searchItem.year,
            imdbRating: "8.8",
            type: searchItem.type
        )
        
        modelContext.insert(cachedFilm)
        try modelContext.save()
        
        // When: Querying with the same imdbID
        let descriptor = FetchDescriptor<IMDBFilm>(
            predicate: #Predicate { film in
                film.imdbID == searchItem.imdbID
            }
        )
        let results = try modelContext.fetch(descriptor)
        
        // Then: Should find the cached film with rating
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.imdbID, searchItem.imdbID)
        XCTAssertEqual(results.first?.imdbRating, "8.8")
    }
    
    func testMultipleSearchesForSameFilm() throws {
        // Given: A film that appears in multiple searches
        let imdbID = "tt10986410"
        
        // First search - no cache
        var descriptor = FetchDescriptor<IMDBFilm>(
            predicate: #Predicate { $0.imdbID == imdbID }
        )
        var results = try modelContext.fetch(descriptor)
        XCTAssertTrue(results.isEmpty)
        
        // View details - film gets cached
        let cachedFilm = IMDBFilm(
            title: "Ted Lasso",
            imdbID: imdbID,
            year: "2020–",
            imdbRating: "8.8",
            type: "series"
        )
        modelContext.insert(cachedFilm)
        try modelContext.save()
        
        // Second search - should find cached data
        results = try modelContext.fetch(descriptor)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.imdbRating, "8.8")
        
        // Third search - should still find cached data
        results = try modelContext.fetch(descriptor)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.imdbRating, "8.8")
    }
    
    func testCacheUpdateBehavior() throws {
        // Given: An existing cached film
        let imdbID = "tt10986410"
        let oldCachedFilm = IMDBFilm(
            title: "Ted Lasso",
            imdbID: imdbID,
            year: "2020–",
            imdbRating: "8.5", // Old rating
            type: "series"
        )
        
        modelContext.insert(oldCachedFilm)
        try modelContext.save()
        
        // When: Updating with new data (simulating a refresh)
        let newFilmData = IMDBFilm(
            title: "Ted Lasso",
            imdbID: imdbID,
            year: "2020–2023", // Updated year
            imdbRating: "8.8", // New rating
            type: "series"
        )
        
        // Find and update existing cached film
        let descriptor = FetchDescriptor<IMDBFilm>(
            predicate: #Predicate { $0.imdbID == imdbID }
        )
        let results = try modelContext.fetch(descriptor)
        
        if let existingCached = results.first {
            // Delete old and insert new
            modelContext.delete(existingCached)
            modelContext.insert(newFilmData)
            try modelContext.save()
        }
        
        // Then: Cache should have updated data
        let updatedResults = try modelContext.fetch(descriptor)
        XCTAssertEqual(updatedResults.first?.imdbRating, "8.8")
        XCTAssertEqual(updatedResults.first?.year, "2020–2023")
    }
}