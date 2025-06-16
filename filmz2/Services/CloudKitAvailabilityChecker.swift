//
//  CloudKitAvailabilityChecker.swift
//  filmz2
//
//  Created by Claude on 15.06.25.
//

import CloudKit
import Foundation
import os.log

/// CloudKit availability checker that makes direct CloudKit API calls
/// to trigger iOS system prompts for iCloud login when necessary.
/// 
/// This approach mimics the old filmz behavior where direct CloudKit calls
/// would automatically prompt the user to sign into iCloud when needed.
@MainActor
class CloudKitAvailabilityChecker: ObservableObject {
    
    private let logger = Logger(subsystem: "com.grtnr.filmz2", category: "CloudKitChecker")
    private let container: CKContainer
    
    /// Initialize with the app's CloudKit container
    init() {
        self.container = CKContainer(identifier: AppConfig.Services.cloudKitContainer)
    }
    
    /// Performs a lightweight CloudKit operation to trigger system iCloud prompts.
    /// This method makes a direct CloudKit API call that will cause iOS to
    /// automatically show iCloud login prompts if the user is not signed in.
    ///
    /// The operation is designed to be minimal but sufficient to trigger the system:
    /// - Checks account status via CloudKit API
    /// - Performs a simple database query
    /// - Lets iOS handle any iCloud authentication prompts
    func checkCloudKitAvailability() async {
        logger.info("Checking CloudKit availability...")
        
        do {
            // First, check account status - this triggers system prompts if needed
            let accountStatus = try await container.accountStatus()
            logger.info("CloudKit account status: \(String(describing: accountStatus))")
            
            switch accountStatus {
            case .available:
                // Account is available, perform a minimal database operation
                // to ensure CloudKit is working and trigger any additional prompts
                await performMinimalDatabaseCheck()
                
            case .noAccount:
                logger.warning("No iCloud account - system should have prompted user")
                // Try a more aggressive operation that's more likely to trigger prompts
                await attemptCloudKitOperation()
                
            case .restricted:
                logger.warning("iCloud account is restricted")
                
            case .couldNotDetermine:
                logger.error("Could not determine iCloud account status")
                
            case .temporarilyUnavailable:
                logger.warning("iCloud is temporarily unavailable")
                
            @unknown default:
                logger.error("Unknown CloudKit account status: \(accountStatus.rawValue)")
            }
            
        } catch {
            // CloudKit errors here are expected and normal when not signed in
            // The act of making the API call triggers system prompts
            logger.info("CloudKit check completed with expected error: \(error.localizedDescription)")
        }
    }
    
    /// Performs a minimal database operation to ensure CloudKit is accessible.
    /// This creates a very lightweight query that doesn't return actual data
    /// but confirms database access and may trigger additional system prompts.
    private func performMinimalDatabaseCheck() async {
        do {
            // Perform a minimal query to the private database
            // This ensures we can access CloudKit and may trigger additional prompts
            // Use TRUEPREDICATE which is always valid in CloudKit
            let query = CKQuery(recordType: "CD_MyFilm", predicate: NSPredicate(value: true))
            
            let database = container.privateCloudDatabase
            let (_, _) = try await database.records(matching: query, resultsLimit: 1)
            
            logger.info("CloudKit database access confirmed")
            
        } catch {
            // Expected when database is empty or during first access
            logger.info("Minimal database check completed: \(error.localizedDescription)")
        }
    }
    
    /// Attempts a more aggressive CloudKit operation when no account is detected.
    /// This tries to perform an actual database operation that should definitely
    /// trigger system prompts for iCloud login.
    private func attemptCloudKitOperation() async {
        do {
            logger.info("Attempting aggressive CloudKit operation to trigger system prompts...")
            
            // Try to access the private database directly
            let database = container.privateCloudDatabase
            
            // Attempt a simple query that requires iCloud authentication
            let query = CKQuery(recordType: "CD_MyFilm", predicate: NSPredicate(format: "TRUEPREDICATE"))
            let (_, _) = try await database.records(matching: query, resultsLimit: 1)
            
            logger.info("Unexpected success - CloudKit operation completed despite no account")
            
        } catch let error as CKError {
            logger.info("CloudKit operation failed as expected: \(error.localizedDescription)")
            
            // Log specific CloudKit error codes that might indicate prompts were shown
            switch error.code {
            case .notAuthenticated:
                logger.info("Not authenticated error - system should have prompted for iCloud")
            case .accountTemporarilyUnavailable:
                logger.info("Account temporarily unavailable")
            default:
                logger.info("Other CloudKit error: \(error.code.rawValue)")
            }
            
        } catch {
            logger.info("Non-CloudKit error during aggressive operation: \(error.localizedDescription)")
        }
    }
}