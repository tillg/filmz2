# CloudKit Integration Unit Testing

[TOC]

## Overview

Implement comprehensive unit tests to verify CloudKit integration works correctly for both MyFilm and IMDBFilm entities. Tests should create identifiable test data, write it to CloudKit via our services, and verify it can be read back from CloudKit.

## Requirements

### Core Testing Goals

1. **End-to-End Validation**: Verify complete write → sync → read cycle
2. **Service Integration**: Test through existing MyFilmsStore and IMDBFilmManager services
3. **CloudKit Verification**: Ensure data actually reaches CloudKit (not just local cache)
4. **Clean Test Data**: Use identifiable test data that can be safely cleaned up
5. **Cross-Device Simulation**: Verify data appears on "different devices" (separate test contexts)

### Entities to Test

* MyFilm
* IMDBFilm

Both should be synced to CloudKit, and that's what we want to really ensure.

## Implementation Plan

### Phase 0: Rework structure for testability

In order to have an architecture that clearly separates the different layers, we separate the responsibility and create specific services that only deal with the writing and reading into / from CloudKit.

We call them

* IMDBFilmCloudKitManager
* MyFilmCloudKitManager

Those services have NO cache, they simply return what they read from CloudKit.

#### CloudKit Manager Service Functions

Both `IMDBFilmCloudKitManager` and `MyFilmCloudKitManager` follow the same interface pattern, providing direct CloudKit access without caching layers. Here are the core functions they implement:

##### Read Operations

```swift
// Fetch a single record by CloudKit record ID
func fetch(recordID: CKRecord.ID) async throws -> EntityType?

// Query records with predicate (e.g., find by imdbID)
func query(predicate: NSPredicate) async throws -> [EntityType]

// Fetch all records of this entity type
func fetchAll() async throws -> [EntityType]

// Check if a record exists without fetching full data
func recordExists(recordID: CKRecord.ID) async throws -> Bool
```

##### Write Operations

```swift
// Save a new record to CloudKit
func save(_ entity: EntityType) async throws -> CKRecord.ID

// Update an existing record in CloudKit
func update(_ entity: EntityType, recordID: CKRecord.ID) async throws

// Batch save multiple records
func saveBatch(_ entities: [EntityType]) async throws -> [CKRecord.ID]
```

##### Delete Operations

```swift
// Delete a single record by ID
func delete(recordID: CKRecord.ID) async throws

// Delete multiple records
func deleteBatch(recordIDs: [CKRecord.ID]) async throws

// Delete records matching a query
func deleteMatching(predicate: NSPredicate) async throws -> Int
```

##### Test Support Function

```swift
// Clean up all test records (those marked with test identifiers)
func cleanupTestRecords() async throws -> Int
```

##### Configuration and Health

```swift
// Check CloudKit availability and account status
func checkCloudKitStatus() async throws -> CloudKitAccountStatus

// Get container configuration info
func getContainerInfo() async throws -> CloudKitContainerInfo

// Monitor sync operations
func monitorSyncOperations() -> AsyncStream<CloudKitSyncEvent>
```

These services provide a **cache-free, direct CloudKit interface** that enables:

1. **True CloudKit Testing**: Bypass SwiftData to verify actual CloudKit operations
2. **Deterministic Results**: No local cache interference in test results  
3. **Raw Data Access**: Direct CKRecord manipulation for debugging
4. **Sync Verification**: Confirm data actually reached CloudKit servers
5. **Test Isolation**: Clean separation between test data and production data

The key difference from existing services (MyFilmsStore, IMDBFilmManager) is that these CloudKit managers have **no local caching or SwiftData integration** - they are pure CloudKit operations.

### Phase 1: Test Infrastructure Setup

#### 1.1 CloudKit Test Environment Configuration

Since creating a new Environment is _very_ complex, and since testing the Environment setting is also part of what we want to test, we use the standard CloudKit container (`iCloud.com.grtnr.filmz2.data`).

#### 1.2 Test Helper Utilities

```swift
// CloudKitTestHelpers.swift
class CloudKitTestHelpers {
    static func createTestMyFilm() -> MyFilm
    static func cleanupTestData() async throws
    static func verifyDataInCloudKit<T>(entity: T) async throws -> Bool
}
```

**Tasks:**

* [ ] Build test data creation utilities
* [ ] Create cleanup utilities for test data
* [ ] Add CloudKit verification helpers

### Phase 2: MyFilm CloudKit Tests

#### 2.1 Basic CRUD Operations Test

```swift
class MyFilmCloudKitTests: XCTestCase {
    func testCreateAndSyncMyFilm() async throws
    func testUpdateMyFilmSyncsToCloudKit() async throws
    func testDeleteMyFilmRemovesFromCloudKit() async throws
}
```

**Test Scenarios:**

Before all test scenarios we will first delete the all data with test markers.

* Create MyFilm with test identifier → Verify in CloudKit
* Update MyFilm properties → Verify changes sync to CloudKit
* Delete MyFilm → Verify removal from CloudKit
* Batch operations → Verify all changes sync correctly

#### 2.2 Cross-Context Sync Tests

```swift
func testMyFilmSyncsBetweenContexts() async throws {
    // Simulate different devices by using separate ModelContexts
    let context1 = // First "device" context
    let context2 = // Second "device" context
    
    // Create in context1, verify appears in context2
}
```

**Test Scenarios:**

* Multi-device simulation using separate contexts
* Conflict resolution testing
* Sync timing and reliability verification

### Phase 3: IMDBFilm CloudKit Testing Strategy

Same pattern as for MyFilm.

## Technical Implementation Details

### Test Data Management

#### Identifiable Test Data Pattern

```swift
extension MyFilm {
    static func createTestInstance() -> MyFilm {
        let film = MyFilm()
        film.imdbID = "TEST_\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
        film.notes = "CloudKit Test Data - Safe to Delete"
        return film
    }
    
    var isTestData: Bool {
        return imdbID.hasPrefix("TEST_")
    }
}
```

#### Cleanup Strategy

```swift
class CloudKitTestCleanup {
    static func cleanupAllTestData() async throws {
        // Query for all test data (imdbID starts with "TEST_")
        // Delete from local SwiftData
        // Verify deletion syncs to CloudKit
        // Clean up any orphaned CloudKit records
    }
}
```
