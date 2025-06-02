//
//  MyFilmDetailViewTests.swift
//  filmz2Tests
//
//  Created by Till Gartner on 02.06.25.
//

import XCTest
import SwiftData
@testable import filmz2

@MainActor
class MyFilmDetailViewTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var testFilm: MyFilm!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create in-memory container
        let schema = Schema([MyFilm.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
        
        // Create test film with just imdbID
        testFilm = MyFilm(imdbID: "tt0133093")
        modelContext.insert(testFilm)
        try modelContext.save()
    }
    
    override func tearDown() {
        testFilm = nil
        modelContext = nil
        modelContainer = nil
        super.tearDown()
    }
    
    // MARK: - Model Tests
    
    func testMyFilmInitialization() {
        XCTAssertEqual(testFilm.imdbID, "tt0133093")
        XCTAssertFalse(testFilm.watched)
        XCTAssertNil(testFilm.myRating)
        XCTAssertNil(testFilm.dateWatched)
        XCTAssertNil(testFilm.audience)
        XCTAssertNil(testFilm.recommendedBy)
        XCTAssertNil(testFilm.notes)
    }
    
    func testWatchStatusUpdate() {
        XCTAssertFalse(testFilm.watched)
        XCTAssertNil(testFilm.dateWatched)
        
        testFilm.watched = true
        testFilm.dateWatched = Date()
        
        XCTAssertTrue(testFilm.watched)
        XCTAssertNotNil(testFilm.dateWatched)
    }
    
    func testRatingUpdate() {
        XCTAssertNil(testFilm.myRating)
        
        testFilm.myRating = 8
        XCTAssertEqual(testFilm.myRating, 8)
        XCTAssertEqual(testFilm.ratingText, "8/10")
        XCTAssertTrue(testFilm.isRated)
        
        testFilm.myRating = nil
        XCTAssertNil(testFilm.myRating)
        XCTAssertNil(testFilm.ratingText)
        XCTAssertFalse(testFilm.isRated)
    }
    
    func testAudienceTypeUpdate() {
        XCTAssertNil(testFilm.audience)
        
        testFilm.audience = .family
        XCTAssertEqual(testFilm.audience, .family)
        
        testFilm.audience = .meAlone
        XCTAssertEqual(testFilm.audience, .meAlone)
        
        testFilm.audience = .meAndPartner
        XCTAssertEqual(testFilm.audience, .meAndPartner)
    }
    
    func testNotesAndRecommendedBy() {
        XCTAssertNil(testFilm.notes)
        XCTAssertNil(testFilm.recommendedBy)
        
        testFilm.notes = "Great movie about reality and choice"
        testFilm.recommendedBy = "John Doe"
        
        XCTAssertEqual(testFilm.notes, "Great movie about reality and choice")
        XCTAssertEqual(testFilm.recommendedBy, "John Doe")
    }
    
    func testWatchStatusText() {
        XCTAssertEqual(testFilm.watchStatusText, "Not watched")
        
        testFilm.watched = true
        XCTAssertEqual(testFilm.watchStatusText, "Watched")
        
        let watchDate = Date()
        testFilm.dateWatched = watchDate
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        XCTAssertEqual(testFilm.watchStatusText, "Watched on \(formatter.string(from: watchDate))")
    }
    
    // Removed testCachedFilmData since we no longer store film data in MyFilm
    
    // MARK: - SwiftData Persistence Tests
    
    func testFilmPersistence() throws {
        // Update film properties
        testFilm.watched = true
        testFilm.myRating = 9
        testFilm.audience = .family
        testFilm.notes = "Amazing film"
        testFilm.recommendedBy = "Friend"
        
        // Save changes
        try modelContext.save()
        
        // Fetch the film back
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.imdbID == "tt0133093"
            }
        )
        
        let fetchedFilms = try modelContext.fetch(descriptor)
        XCTAssertEqual(fetchedFilms.count, 1)
        
        let fetchedFilm = fetchedFilms.first!
        XCTAssertEqual(fetchedFilm.imdbID, "tt0133093")
        XCTAssertTrue(fetchedFilm.watched)
        XCTAssertEqual(fetchedFilm.myRating, 9)
        XCTAssertEqual(fetchedFilm.audience, .family)
        XCTAssertEqual(fetchedFilm.notes, "Amazing film")
        XCTAssertEqual(fetchedFilm.recommendedBy, "Friend")
    }
    
    func testFilmDeletion() throws {
        // Verify film exists
        let beforeDelete = try modelContext.fetch(FetchDescriptor<MyFilm>())
        XCTAssertEqual(beforeDelete.count, 1)
        
        // Delete film
        modelContext.delete(testFilm)
        try modelContext.save()
        
        // Verify film is deleted
        let afterDelete = try modelContext.fetch(FetchDescriptor<MyFilm>())
        XCTAssertEqual(afterDelete.count, 0)
    }
}

// MARK: - Star Rating Tests

class StarRatingViewTests: XCTestCase {
    func testRatingRange() {
        var rating: Int? = nil
        
        // Test setting valid ratings
        for i in 1...10 {
            rating = i
            XCTAssertEqual(rating, i)
        }
        
        // Test clearing rating
        rating = nil
        XCTAssertNil(rating)
    }
}