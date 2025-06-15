import Foundation
import SwiftData

/// Manages persistent caching of IMDB film metadata to reduce API calls and enable offline access.
/// Provides save, fetch, and cache management operations for IMDBFilm objects.
@MainActor
class CacheManager {
    static let shared = CacheManager()
    
    private var modelContext: ModelContext?
    
    private init() {
        // Will be initialized when accessed
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("CacheManager: Using shared model context")
    }
    
    func saveFilm(_ film: IMDBFilm) {
        guard let context = modelContext else {
            print("CacheManager: No context available for saving")
            return
        }
        
        // Check if already exists
        let descriptor = FetchDescriptor<IMDBFilm>(
            predicate: #Predicate { cached in
                cached.imdbID == film.imdbID
            }
        )
        
        do {
            let existing = try context.fetch(descriptor)
            for old in existing {
                context.delete(old)
            }
            
            // Update cache metadata and insert
            film.updateCacheMetadata()
            context.insert(film)
            try context.save()
            
            print("CacheManager: Cached film '\(film.title)' with rating \(film.imdbRating ?? "nil")")
        } catch {
            print("CacheManager: Failed to save film: \(error)")
        }
    }
    
    func fetchFilm(imdbID: String) -> IMDBFilm? {
        guard let context = modelContext else {
            print("CacheManager: No context available for fetching")
            return nil
        }
        
        let descriptor = FetchDescriptor<IMDBFilm>(
            predicate: #Predicate { film in
                film.imdbID == imdbID
            }
        )
        
        do {
            let films = try context.fetch(descriptor)
            if let film = films.first {
                print("CacheManager: Found cached film '\(film.title)' with rating \(film.imdbRating ?? "nil")")
            }
            return films.first
        } catch {
            print("CacheManager: Failed to fetch film: \(error)")
            return nil
        }
    }
    
    func fetchAllFilms() -> [IMDBFilm] {
        guard let context = modelContext else {
            print("CacheManager: No context available for fetching all")
            return []
        }
        
        do {
            let descriptor = FetchDescriptor<IMDBFilm>(
                sortBy: [SortDescriptor(\.lastFetched, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("CacheManager: Failed to fetch all films: \(error)")
            return []
        }
    }
    
    func clearCache() {
        guard let context = modelContext else { return }
        
        do {
            let all = try context.fetch(FetchDescriptor<IMDBFilm>())
            for film in all {
                context.delete(film)
            }
            try context.save()
            print("CacheManager: Cache cleared")
        } catch {
            print("CacheManager: Failed to clear cache: \(error)")
        }
    }
}