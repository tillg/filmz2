import Foundation
import SwiftData

/// Manages the MyFilms database separately from the main app database
@MainActor
class MyFilmsManager {
    static let shared = MyFilmsManager()
    
    private var modelContainer: ModelContainer?
    private var modelContext: ModelContext?
    
    private init() {
        setupContainer()
    }
    
    private func setupContainer() {
        do {
            let schema = Schema([MyFilm.self])
            
            // Use a different store name to avoid conflicts
            let storeURL = URL.applicationSupportDirectory.appending(path: "filmz2_myfilms.store")
            
            let modelConfiguration = ModelConfiguration(url: storeURL)
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            modelContext = ModelContext(modelContainer!)
            
            print("MyFilmsManager: MyFilms database initialized successfully")
        } catch {
            print("MyFilmsManager: Failed to initialize MyFilms database: \(error)")
            // Fall back to in-memory store
            do {
                let schema = Schema([MyFilm.self])
                let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                modelContext = ModelContext(modelContainer!)
                print("MyFilmsManager: Using in-memory store as fallback")
            } catch {
                print("MyFilmsManager: Failed to create even in-memory store: \(error)")
            }
        }
    }
    
    var context: ModelContext? {
        return modelContext
    }
    
    func getStore() -> MyFilmsStore? {
        guard let context = modelContext else { return nil }
        return MyFilmsStore(modelContext: context)
    }
    
    // MARK: - Direct Database Operations
    
    func fetchFilms() -> [MyFilm] {
        guard let context = modelContext else { return [] }
        
        do {
            let descriptor = FetchDescriptor<MyFilm>(
                sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
            )
            return try context.fetch(descriptor)
        } catch {
            print("MyFilmsManager: Failed to fetch films: \(error)")
            return []
        }
    }
    
    func addFilm(from searchItem: OMDBSearchItem) async throws -> MyFilm {
        guard let context = modelContext else {
            throw MyFilmsStoreError.saveFailed(NSError(domain: "MyFilmsManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"]))
        }
        
        // Check if film already exists
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.imdbID == searchItem.imdbID
            }
        )
        
        if let _ = try context.fetch(descriptor).first {
            throw MyFilmsStoreError.filmAlreadyExists(searchItem.title)
        }
        
        // Fetch full film details to ensure it's cached
        _ = try await OMDBSearchService.shared.getFilm(byID: searchItem.imdbID)
        
        let myFilm = MyFilm(from: searchItem)
        context.insert(myFilm)
        
        do {
            try context.save()
            return myFilm
        } catch {
            throw MyFilmsStoreError.saveFailed(error)
        }
    }
    
    func addFilm(from imdbFilm: IMDBFilm) async throws -> MyFilm {
        guard let context = modelContext else {
            throw MyFilmsStoreError.saveFailed(NSError(domain: "MyFilmsManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"]))
        }
        
        // Check if film already exists
        let descriptor = FetchDescriptor<MyFilm>(
            predicate: #Predicate { film in
                film.imdbID == imdbFilm.imdbID
            }
        )
        
        if let _ = try context.fetch(descriptor).first {
            throw MyFilmsStoreError.filmAlreadyExists(imdbFilm.title)
        }
        
        let myFilm = MyFilm(from: imdbFilm)
        context.insert(myFilm)
        
        do {
            try context.save()
            return myFilm
        } catch {
            throw MyFilmsStoreError.saveFailed(error)
        }
    }
    
    func isFilmInCollection(_ imdbID: String) -> Bool {
        guard let context = modelContext else { return false }
        
        do {
            let descriptor = FetchDescriptor<MyFilm>(
                predicate: #Predicate { film in
                    film.imdbID == imdbID
                }
            )
            return try context.fetch(descriptor).first != nil
        } catch {
            print("MyFilmsManager: Error checking film existence: \(error)")
            return false
        }
    }
    
    func getFilm(by imdbID: String) -> MyFilm? {
        guard let context = modelContext else { return nil }
        
        do {
            let descriptor = FetchDescriptor<MyFilm>(
                predicate: #Predicate { film in
                    film.imdbID == imdbID
                }
            )
            return try context.fetch(descriptor).first
        } catch {
            print("MyFilmsManager: Error fetching film: \(error)")
            return nil
        }
    }
}