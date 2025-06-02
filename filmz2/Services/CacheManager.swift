import Foundation
import SwiftData

/// Manages the cache database separately from the main app database
class CacheManager {
    static let shared = CacheManager()
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    private init() {
        setupContainer()
    }
    
    private func setupContainer() {
        do {
            let schema = Schema([CachedIMDBFilm.self])
            
            // Use a different store name to avoid conflicts
            let storeURL = URL.applicationSupportDirectory.appending(path: "filmz2_cache.store")
            
            let modelConfiguration = ModelConfiguration(url: storeURL)
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            modelContext = ModelContext(modelContainer!)
            
            print("CacheManager: Cache database initialized successfully")
        } catch {
            print("CacheManager: Failed to initialize cache database: \(error)")
            // Fall back to in-memory store
            do {
                let schema = Schema([CachedIMDBFilm.self])
                let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                modelContext = ModelContext(modelContainer!)
                print("CacheManager: Using in-memory cache as fallback")
            } catch {
                print("CacheManager: Failed to create even in-memory cache: \(error)")
            }
        }
    }
    
    func saveFilm(_ film: IMDBFilm) {
        guard let context = modelContext else {
            print("CacheManager: No context available for saving")
            return
        }
        
        // Check if already exists
        let descriptor = FetchDescriptor<CachedIMDBFilm>(
            predicate: #Predicate { cached in
                cached.imdbID == film.imdbID
            }
        )
        
        do {
            let existing = try context.fetch(descriptor)
            for old in existing {
                context.delete(old)
            }
            
            let cachedFilm = CachedIMDBFilm(from: film)
            context.insert(cachedFilm)
            try context.save()
            
            print("CacheManager: Cached film '\(film.title)' with rating \(film.imdbRating ?? "nil")")
        } catch {
            print("CacheManager: Failed to save film: \(error)")
        }
    }
    
    func fetchFilm(imdbID: String) -> CachedIMDBFilm? {
        guard let context = modelContext else {
            print("CacheManager: No context available for fetching")
            return nil
        }
        
        let descriptor = FetchDescriptor<CachedIMDBFilm>(
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
    
    func fetchAllFilms() -> [CachedIMDBFilm] {
        guard let context = modelContext else {
            print("CacheManager: No context available for fetching all")
            return []
        }
        
        do {
            let descriptor = FetchDescriptor<CachedIMDBFilm>(
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
            let all = try context.fetch(FetchDescriptor<CachedIMDBFilm>())
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