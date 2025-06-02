//
//  MyFilmsStore.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class MyFilmsStore: ObservableObject {
    var modelContext: ModelContext
    
    @Published var films: [MyFilm] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchFilms()
    }
    
    // MARK: - CRUD Operations
    
    func fetchFilms() {
        do {
            let descriptor = FetchDescriptor<MyFilm>(
                sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
            )
            films = try modelContext.fetch(descriptor)
        } catch {
            self.error = error
            print("Failed to fetch films: \(error)")
        }
    }
    
    func addFilm(from searchItem: OMDBSearchItem) async throws -> MyFilm {
        // Check if film already exists
        if let existingFilm = try? getFilm(by: searchItem.imdbID) {
            throw MyFilmsStoreError.filmAlreadyExists(existingFilm.title)
        }
        
        let myFilm = MyFilm(from: searchItem)
        modelContext.insert(myFilm)
        
        do {
            try modelContext.save()
            fetchFilms()
            return myFilm
        } catch {
            throw MyFilmsStoreError.saveFailed(error)
        }
    }
    
    func addFilm(from imdbFilm: IMDBFilm) async throws -> MyFilm {
        // Check if film already exists
        if let existingFilm = try? getFilm(by: imdbFilm.imdbID) {
            throw MyFilmsStoreError.filmAlreadyExists(existingFilm.title)
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
    
    func updateFilm(_ film: MyFilm) throws {
        do {
            try modelContext.save()
            fetchFilms()
        } catch {
            throw MyFilmsStoreError.saveFailed(error)
        }
    }
    
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
    
    func getFilm(by imdbID: String) throws -> MyFilm? {
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.imdbID == imdbID
            }
        )
        
        return try modelContext.fetch(descriptor).first
    }
    
    func isFilmInCollection(_ imdbID: String) -> Bool {
        do {
            return try getFilm(by: imdbID) != nil
        } catch {
            print("Error checking film existence: \(error)")
            return false
        }
    }
    
    func getWatchedFilms() throws -> [MyFilm] {
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.watched == true
            },
            sortBy: [SortDescriptor(\.dateWatched, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
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
    
    func markAsWatched(_ film: MyFilm, date: Date = Date()) throws {
        film.watched = true
        film.dateWatched = date
        try updateFilm(film)
    }
    
    func rateFilm(_ film: MyFilm, rating: Int) throws {
        guard rating >= 0 && rating <= 10 else {
            throw MyFilmsStoreError.invalidRating
        }
        
        film.myRating = rating
        try updateFilm(film)
    }
    
    // MARK: - Statistics
    
    var totalFilmsCount: Int {
        films.count
    }
    
    var watchedFilmsCount: Int {
        films.filter { $0.watched }.count
    }
    
    var unwatchedFilmsCount: Int {
        films.filter { !$0.watched }.count
    }
}

// MARK: - Error Types

enum MyFilmsStoreError: LocalizedError {
    case filmAlreadyExists(String) // Store title instead of MyFilm
    case saveFailed(Error)
    case deleteFailed(Error)
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

struct MyFilmsStoreKey: EnvironmentKey {
    static let defaultValue: MyFilmsStore? = nil
}

extension EnvironmentValues {
    var myFilmsStore: MyFilmsStore? {
        get { self[MyFilmsStoreKey.self] }
        set { self[MyFilmsStoreKey.self] = newValue }
    }
}