//
//  MyFilmsStore.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

import Foundation
import SwiftData
import SwiftUI

/// ObservableObject service for managing user's personal film collection.
/// Provides CRUD operations, querying capabilities, and real-time updates for SwiftUI views.
/// 
/// **Architecture Role:**
/// - Primary interface for MyFilm data management
/// - Bridges SwiftData persistence with SwiftUI reactive updates
/// - Implements ID-only pattern: stores IMDB IDs, not full film metadata
/// - Complements MyFilmsManager (provides convenience methods for specific use cases)
/// 
/// **Thread Safety:**
/// - Annotated with @MainActor for UI thread safety
/// - All operations guaranteed to run on main thread
/// - Safe for direct use in SwiftUI views and view models
/// 
/// **Error Handling Strategy:**
/// - Structured errors via MyFilmsStoreError enum
/// - Automatic error publishing via @Published error property
/// - Graceful degradation (operations continue on partial failures)
/// - Detailed logging for debugging
/// 
/// **Performance Characteristics:**
/// - Batch operations: Automatic fetchFilms() refresh after modifications
/// - Query optimization: Uses SwiftData FetchDescriptor with predicates
/// - Memory efficiency: Only stores essential user data (not film metadata)
@MainActor
class MyFilmsStore: ObservableObject {
    /// SwiftData model context for persistence operations
    var modelContext: ModelContext
    
    /// Reactive collection of user's films, automatically updated after modifications
    @Published var films: [MyFilm] = []
    /// Loading state indicator for UI feedback
    @Published var isLoading = false
    /// Current error state, automatically published to UI
    @Published var error: Error?
    
    /// Initializes the store with a SwiftData model context.
    /// Automatically performs initial data fetch on creation.
    /// 
    /// - Parameter modelContext: SwiftData context for persistence operations
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchFilms()
    }
    
    // MARK: - CRUD Operations
    
    /// Fetches all films from persistent storage and updates the published films array.
    /// **Sorting Strategy:** Most recently added films appear first (reverse chronological)
    /// **Error Handling:** Sets error property on failure, UI can react accordingly
    /// **Performance:** Efficient single-query fetch with SwiftData descriptors
    func fetchFilms() {
        do {
            let descriptor = FetchDescriptor<MyFilm>(
                sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
            )
            films = try modelContext.fetch(descriptor)
            print("MyFilmsStore: Fetched \(films.count) films")
            for film in films {
                print("  - \(film.imdbID): \(film.dateAdded)")
            }
        } catch {
            self.error = error
            print("Failed to fetch films: \(error)")
        }
    }
    
    /// Adds a film to the collection from an OMDB search result.
    /// **ID-Only Pattern:** Stores only IMDB ID and user data, not full film metadata
    /// **Duplicate Prevention:** Checks for existing films before insertion
    /// **Lazy Loading:** Film details fetched on-demand by views (performance optimization)
    /// 
    /// **Transaction Safety:**
    /// 1. Duplicate check (throws if exists)
    /// 2. Model insertion
    /// 3. Persistence save
    /// 4. UI refresh (fetchFilms)
    /// 
    /// - Parameter searchItem: OMDB search result containing basic film info
    /// - Returns: Newly created MyFilm instance
    /// - Throws: MyFilmsStoreError.filmAlreadyExists or MyFilmsStoreError.saveFailed
    func addFilm(from searchItem: OMDBSearchItem) async throws -> MyFilm {
        // Check if film already exists
        if (try? getFilm(by: searchItem.imdbID)) != nil {
            throw MyFilmsStoreError.filmAlreadyExists(searchItem.title)
        }
        
        // Note: Film details will be fetched when needed by the view
        // This avoids unnecessary API calls and makes testing easier
        
        let myFilm = MyFilm(from: searchItem)
        modelContext.insert(myFilm)
        
        do {
            try modelContext.save()
            print("MyFilmsStore: Successfully saved film \(myFilm.imdbID)")
            fetchFilms()
            return myFilm
        } catch {
            print("MyFilmsStore: Failed to save film: \(error)")
            throw MyFilmsStoreError.saveFailed(error)
        }
    }
    
    /// Adds a film to the collection from complete IMDB film data.
    /// **Alternative Entry Point:** Used when full film details are already available
    /// **Automatic Caching:** Film details saved to persistent cache via CacheManager
    /// 
    /// **Use Cases:**
    /// - Adding from film detail view
    /// - Bulk import operations
    /// - Testing with complete film data
    /// 
    /// - Parameter imdbFilm: Complete film data from OMDB API
    /// - Returns: Newly created MyFilm instance
    /// - Throws: MyFilmsStoreError.filmAlreadyExists or MyFilmsStoreError.saveFailed
    func addFilm(from imdbFilm: IMDBFilm) async throws -> MyFilm {
        // Check if film already exists
        if (try? getFilm(by: imdbFilm.imdbID)) != nil {
            throw MyFilmsStoreError.filmAlreadyExists(imdbFilm.title)
        }
        
        let myFilm = MyFilm(from: imdbFilm)
        modelContext.insert(myFilm)
        
        do {
            try modelContext.save()
            fetchFilms()
            return myFilm
        } catch {
            throw MyFilmsStoreError.saveFailed(error)
        }
    }
    
    /// Updates an existing film's user data in persistent storage.
    /// **In-Place Updates:** Modifies existing MyFilm properties, then persists
    /// **Automatic Refresh:** Updates UI-bound films array after successful save
    /// 
    /// **Common Update Scenarios:**
    /// - User rating changes
    /// - Watched status modifications
    /// - Notes or recommendation updates
    /// - Audience type classifications
    /// 
    /// - Parameter film: MyFilm instance with modified properties
    /// - Throws: MyFilmsStoreError.saveFailed on persistence errors
    func updateFilm(_ film: MyFilm) throws {
        do {
            try modelContext.save()
            fetchFilms()
        } catch {
            throw MyFilmsStoreError.saveFailed(error)
        }
    }
    
    /// Removes a film from the user's collection.
    /// **Data Retention:** Only removes user data, film metadata remains in cache
    /// **Cascade Behavior:** No cascade deletion (film metadata preserved for other users)
    /// 
    /// **Safety Considerations:**
    /// - Cannot be undone (consider confirmation dialogs in UI)
    /// - Does not affect shared film metadata cache
    /// - Preserves film availability for re-addition
    /// 
    /// - Parameter film: MyFilm instance to remove from collection
    /// - Throws: MyFilmsStoreError.deleteFailed on persistence errors
    func deleteFilm(_ film: MyFilm) throws {
        modelContext.delete(film)
        
        do {
            try modelContext.save()
            fetchFilms()
        } catch {
            throw MyFilmsStoreError.deleteFailed(error)
        }
    }
    
    // MARK: - Query Operations
    
    /// Retrieves a specific film from the collection by IMDB ID.
    /// **Primary Key Lookup:** Uses IMDB ID as unique identifier
    /// **Efficient Query:** SwiftData predicate-based filtering
    /// 
    /// **Performance:** O(log n) lookup via SwiftData indexing
    /// **Thread Safety:** Synchronous operation safe on main actor
    /// 
    /// - Parameter imdbID: Unique IMDB identifier (e.g., "tt1234567")
    /// - Returns: MyFilm instance if found, nil otherwise
    /// - Throws: SwiftData fetch errors (rare, typically indicates data corruption)
    func getFilm(by imdbID: String) throws -> MyFilm? {
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.imdbID == imdbID
            }
        )
        
        return try modelContext.fetch(descriptor).first
    }
    
    /// Checks if a film exists in the user's collection.
    /// **Convenience Method:** Wraps getFilm(by:) with boolean result
    /// **Error Handling:** Returns false on query errors (graceful degradation)
    /// 
    /// **Use Cases:**
    /// - UI state management (show "Add" vs "In Collection")
    /// - Duplicate prevention in user workflows
    /// - Conditional feature availability
    /// 
    /// - Parameter imdbID: IMDB identifier to check
    /// - Returns: true if film exists in collection, false otherwise
    func isFilmInCollection(_ imdbID: String) -> Bool {
        do {
            return try getFilm(by: imdbID) != nil
        } catch {
            print("Error checking film existence: \(error)")
            return false
        }
    }
    
    /// Retrieves all films marked as watched by the user.
    /// **Filtering Strategy:** Boolean predicate for watched status
    /// **Sorting:** Most recently watched films first
    /// 
    /// **UI Integration:** Used by CollectionView watched tab
    /// **Performance:** Indexed query on watched boolean field
    /// 
    /// - Returns: Array of watched films, sorted by watch date (newest first)
    /// - Throws: SwiftData fetch errors
    func getWatchedFilms() throws -> [MyFilm] {
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.watched == true
            },
            sortBy: [SortDescriptor(\.dateWatched, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Retrieves all films not yet watched by the user.
    /// **Filtering Strategy:** Boolean predicate for unwatched status
    /// **Sorting:** Most recently added films first (watch queue priority)
    /// 
    /// **UI Integration:** Used by CollectionView unwatched tab
    /// **User Workflow:** Represents the user's "to watch" queue
    /// 
    /// - Returns: Array of unwatched films, sorted by addition date (newest first)
    /// - Throws: SwiftData fetch errors
    func getUnwatchedFilms() throws -> [MyFilm] {
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.watched == false
            },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Bulk Operations
    
    /// Marks a film as watched with optional custom watch date.
    /// **State Transition:** Updates both watched boolean and dateWatched timestamp
    /// **Default Behavior:** Uses current date if no date specified
    /// 
    /// **UI Integration:** Called from film detail views and quick action buttons
    /// **Data Integrity:** Ensures dateWatched is set when watched=true
    /// 
    /// - Parameters:
    ///   - film: MyFilm instance to mark as watched
    ///   - date: Watch date (defaults to current date)
    /// - Throws: MyFilmsStoreError.saveFailed on persistence errors
    func markAsWatched(_ film: MyFilm, date: Date = Date()) throws {
        film.watched = true
        film.dateWatched = date
        try updateFilm(film)
    }
    
    /// Sets the user's personal rating for a film.
    /// **Validation:** Enforces 0-10 rating scale
    /// **Rating System:** 10-point scale (0=awful, 10=masterpiece)
    /// 
    /// **User Experience:**
    /// - Allows rating both watched and unwatched films
    /// - Supports rating updates (user can change their mind)
    /// - Rating of 0 represents "disliked" not "unrated"
    /// 
    /// - Parameters:
    ///   - film: MyFilm instance to rate
    ///   - rating: Integer rating from 0-10
    /// - Throws: MyFilmsStoreError.invalidRating or MyFilmsStoreError.saveFailed
    func rateFilm(_ film: MyFilm, rating: Int) throws {
        guard rating >= 0 && rating <= 10 else {
            throw MyFilmsStoreError.invalidRating
        }
        
        film.myRating = rating
        try updateFilm(film)
    }
    
    // MARK: - Statistics
    
    /// Total number of films in the user's collection.
    /// **Performance:** O(1) - uses cached films array count
    /// **Real-time:** Automatically updates as films array changes
    var totalFilmsCount: Int {
        films.count
    }
    
    /// Number of films marked as watched by the user.
    /// **Performance:** O(n) - filters films array each access
    /// **Optimization Note:** Consider caching if used frequently
    var watchedFilmsCount: Int {
        films.filter { $0.watched }.count
    }
    
    /// Number of films not yet watched by the user.
    /// **Performance:** O(n) - filters films array each access
    /// **User Context:** Represents size of "to watch" queue
    var unwatchedFilmsCount: Int {
        films.filter { !$0.watched }.count
    }
}

// MARK: - Error Types

/// Structured error types for MyFilmsStore operations.
/// Provides localized error messages for user-facing error handling.
enum MyFilmsStoreError: LocalizedError {
    /// Attempt to add a film that already exists in the collection
    case filmAlreadyExists(String) // Store title instead of MyFilm
    /// Persistence save operation failed
    case saveFailed(Error)
    /// Persistence delete operation failed
    case deleteFailed(Error)
    /// Rating value outside valid 0-10 range
    case invalidRating
    
    var errorDescription: String? {
        switch self {
        case .filmAlreadyExists(let title):
            return "\(title) is already in your collection"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .invalidRating:
            return "Rating must be between 0 and 10"
        }
    }
}

// MARK: - Environment Key

/// SwiftUI environment key for dependency injection of MyFilmsStore.
/// Enables views to access the store without explicit parameter passing.
struct MyFilmsStoreKey: EnvironmentKey {
    static let defaultValue: MyFilmsStore? = nil
}

/// SwiftUI environment extension for MyFilmsStore access.
/// Usage: @Environment(\.myFilmsStore) var store
extension EnvironmentValues {
    var myFilmsStore: MyFilmsStore? {
        get { self[MyFilmsStoreKey.self] }
        set { self[MyFilmsStoreKey.self] = newValue }
    }
}