import Foundation
import SwiftData
import SwiftUI
import os.log

/// Manages the MyFilms database using the shared app container
@MainActor
class MyFilmsManager {
    static let shared = MyFilmsManager()
    
    private var modelContext: ModelContext?
    private let logger = Logger(subsystem: "com.grtnr.filmz2", category: "MyFilmsManager")
    
    private init() {
        // Will be initialized when accessed
        setupCloudKitNotifications()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("MyFilmsManager: Using shared model context")
    }
    
    var context: ModelContext? {
        return modelContext
    }
    
    /// Force CloudKit sync by triggering a save operation
    func forceCloudKitSync() {
        guard let context = modelContext else {
            logger.warning("Cannot force sync: no model context available")
            return
        }
        
        do {
            // This triggers any pending CloudKit uploads
            try context.save()
            logger.info("Forced CloudKit sync triggered")
            print("MyFilmsManager: Forced CloudKit sync triggered")
        } catch {
            logger.error("Failed to force CloudKit sync: \(error.localizedDescription)")
            print("MyFilmsManager: Failed to force CloudKit sync: \(error)")
        }
    }
    
    /// Reset CloudKit sync state after account changes
    func resetCloudKitState() {
        guard let context = modelContext else {
            logger.warning("Cannot reset CloudKit state: no model context available")
            return
        }
        
        logger.info("Resetting CloudKit sync state due to account change")
        print("MyFilmsManager: Resetting CloudKit sync state due to account change")
        
        // Force a save to trigger CloudKit reinitialization
        do {
            try context.save()
            logger.info("CloudKit state reset completed")
            print("MyFilmsManager: CloudKit state reset completed")
        } catch {
            logger.error("Failed to reset CloudKit state: \(error.localizedDescription)")
            print("MyFilmsManager: Failed to reset CloudKit state: \(error)")
        }
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
        // Fetch full film details to ensure it's cached
        let imdbFilm = try await OMDBSearchService.shared.getFilm(byID: searchItem.imdbID)
        return try await addFilm(from: imdbFilm)
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
            logger.info("MyFilmsManager: Successfully added film \(myFilm.imdbID) to collection - queued for CloudKit sync")
            print("MyFilmsManager: Successfully added film \(myFilm.imdbID) to collection - queued for CloudKit sync")
            return myFilm
        } catch {
            logger.error("MyFilmsManager: Failed to save film \(myFilm.imdbID): \(error.localizedDescription)")
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
    
    // MARK: - CloudKit Sync Monitoring
    
    private func setupCloudKitNotifications() {
        // Listen for CloudKit remote change notifications
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.logger.info("CloudKit remote change detected: \(notification.userInfo?.description ?? "no details")")
            print("MyFilmsManager: CloudKit sync activity detected")
        }
        
        // Listen for CloudKit import/export notifications if available
        NotificationCenter.default.addObserver(
            forName: Notification.Name("NSCloudKitMirroringDelegateWillResetSyncNotificationName"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.logger.info("CloudKit sync will reset: \(notification.userInfo?.description ?? "no details")")
            print("MyFilmsManager: CloudKit sync will reset")
        }
        
        NotificationCenter.default.addObserver(
            forName: Notification.Name("NSCloudKitMirroringDelegateDidResetSyncNotificationName"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.logger.info("CloudKit sync did reset: \(notification.userInfo?.description ?? "no details")")
            print("MyFilmsManager: CloudKit sync completed reset")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}