//
//  MyFilmsManagerTests.swift
//  filmz2Tests
//
//  Created by Assistant on 02.06.25.
//

import XCTest
import SwiftData
@testable import filmz2

@MainActor
final class MyFilmsManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Set up an in-memory model context for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: MyFilm.self, CachedIMDBFilm.self, configurations: config)
        let context = ModelContext(container)
        
        // Set the context on the shared manager
        MyFilmsManager.shared.setModelContext(context)
        
        // Clear any existing data
        MyFilmsManager.shared.fetchFilms().forEach { film in
            if let context = MyFilmsManager.shared.context {
                context.delete(film)
                try? context.save()
            }
        }
    }
    
    func testAddFilmFromSearchItem() async throws {
        #if os(macOS)
        // Skip this test on macOS due to network dependency issues in test environment
        throw XCTSkip("Network-dependent test skipped on macOS")
        #else
        // Given
        let searchItem = OMDBSearchItem(
            title: "See",
            year: "2019–2022",
            imdbID: "tt7949218",
            type: "series",
            poster: "https://example.com/poster.jpg"
        )
        
        // When
        do {
            let myFilm = try await MyFilmsManager.shared.addFilm(from: searchItem)
            
            // Then
            XCTAssertNotNil(myFilm)
            XCTAssertEqual(myFilm.imdbID, "tt7949218")
            
            // Verify it's in the collection
            let isInCollection = MyFilmsManager.shared.isFilmInCollection("tt7949218")
            XCTAssertTrue(isInCollection)
            
        } catch {
            XCTFail("Failed to add film: \(error)")
        }
        #endif
    }
    
    func testManagerInitialization() {
        // Test that the manager initializes properly
        let manager = MyFilmsManager.shared
        XCTAssertNotNil(manager.context, "Context should not be nil")
        
        // Test that we can fetch films (even if empty)
        let films = manager.fetchFilms()
        XCTAssertNotNil(films, "Should be able to fetch films array")
    }
    
    func testAddDuplicateFilm() async throws {
        #if os(macOS)
        // Skip this test on macOS due to network dependency issues in test environment
        throw XCTSkip("Network-dependent test skipped on macOS")
        #else
        // Given
        let searchItem = OMDBSearchItem(
            title: "Test Movie",
            year: "2024",
            imdbID: "tt1234567",
            type: "movie",
            poster: nil
        )
        
        // Add the film once
        _ = try await MyFilmsManager.shared.addFilm(from: searchItem)
        
        // When trying to add again
        do {
            _ = try await MyFilmsManager.shared.addFilm(from: searchItem)
            XCTFail("Should have thrown an error for duplicate film")
        } catch let error as MyFilmsStoreError {
            // Then
            switch error {
            case .filmAlreadyExists(let title):
                XCTAssertEqual(title, "Test Movie")
            default:
                XCTFail("Wrong error type: \(error)")
            }
        }
        #endif
    }
}