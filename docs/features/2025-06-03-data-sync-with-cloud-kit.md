
# Feature: CloudKit Data Sync

[TOC]

## Overview

Enable users to seamlessly sync their film collection across all their Apple devices using CloudKit. This feature will automatically sync personal film data (ratings, watch status, notes) while maintaining the existing cache-based architecture.

## Goals

- Users see their film collection on all their devices (iPhone, iPad, Mac)
- Automatic sync without user intervention
- Maintain offline functionality
- Preserve existing architecture patterns
- Zero configuration for users

## Technical Implementation

### 1. CloudKit Container Setup

#### 1.1 Enable CloudKit Capability

- Add CloudKit capability to the app target
- Create CloudKit container: `iCloud.com.grtnr.filmz2`
- Enable CloudKit for both development and production

#### 1.2 Configure Entitlements

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.grtnr.filmz2</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

### 2. SwiftData + CloudKit Integration

#### 2.1 ModelContainer Configuration

Update `filmz2App.swift` to use CloudKit-enabled container:

```swift
import SwiftData

@main
struct filmz2App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MyFilm.self,
            CachedIMDBFilm.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic // Enable CloudKit sync
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

### 3. Data Model Considerations

#### 3.1 MyFilm Model (Synced)

The `MyFilm` model will be synced across devices. Current structure is CloudKit-compatible:

- All properties use supported types (String, Date, Int, Bool, UUID)
- Custom enum `AudienceType` is Codable
- No complex relationships that would complicate sync

#### 3.2 CachedIMDBFilm Model (Local Only)

The cache should remain device-specific to:

- Avoid unnecessary CloudKit storage usage
- Allow each device to manage its own cache lifecycle
- Reduce sync conflicts for frequently changing data

Configure cache container separately:

```swift
let cacheConfiguration = ModelConfiguration(
    schema: Schema([CachedIMDBFilm.self]),
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .none // Disable CloudKit for cache
)
```

### 4. Sync Architecture

#### 4.1 Sync Flow

1. User adds/modifies film in collection → SwiftData saves locally
2. SwiftData + CloudKit automatically syncs to iCloud
3. Other devices receive updates automatically
4. Each device maintains its own cache of film metadata

#### 4.2 Conflict Resolution

SwiftData + CloudKit handles most conflicts automatically using last-write-wins. For custom resolution:

- Monitor `NSPersistentCloudKitContainer` notifications
- Implement merge policies for specific fields if needed

### 5. User Experience

#### 5.1 Sync Status Indicator

Add visual feedback for sync status:

- Small cloud icon in navigation bar
- Shows sync in progress, synced, or offline
- Tap for detailed sync status sheet

#### 5.2 Initial Sync

When user first enables sync:

- Show progress indicator
- Merge any existing local data
- Handle large collections gracefully

#### 5.3 Offline Behavior

- All features work offline
- Changes queue for sync when online
- Clear indication of offline mode

### 6. Implementation Steps

1. **Update App Configuration**
   - Add CloudKit capability
   - Update entitlements file
   - Configure provisioning profiles

2. **Modify ModelContainer Setup**
   - Split containers for synced vs cached data
   - Configure CloudKit database settings
   - Test container initialization

3. **Add Sync Status UI**
   - Create `SyncStatusView` component
   - Add to main navigation
   - Implement status monitoring

4. **Test Sync Scenarios**
   - Single device changes
   - Multi-device simultaneous edits
   - Offline/online transitions
   - Large data sets

5. **Handle Edge Cases**
   - Account sign-in/out
   - iCloud storage full
   - Network failures
   - Data corruption

### 7. Privacy & Security

#### 7.1 Data Privacy

- All data stored in user's private CloudKit database
- No data sharing between users
- Apple handles encryption in transit and at rest

#### 7.2 GDPR Compliance

- Data deletion propagates across devices
- User can disable sync and delete cloud data
- Export functionality remains device-local

### 8. Testing Strategy

#### 8.1 Unit Tests

- Mock CloudKit container for testing
- Test conflict resolution logic
- Verify data model compatibility

#### 8.2 Integration Tests

- Test sync between simulator instances
- Verify offline queue behavior
- Test large dataset performance

#### 8.3 Manual Testing Checklist

- [ ] Add film on Device A, appears on Device B
- [ ] Edit film on Device B, updates on Device A
- [ ] Delete film on Device A, removes from Device B
- [ ] Work offline, changes sync when online
- [ ] Handle iCloud account changes
- [ ] Verify sync status indicators

### 9. Performance Considerations

- Sync only `MyFilm` records (small payload)
- Cache remains local (avoids large transfers)
- Batch sync operations
- Implement sync throttling for rapid changes

### 10. Data Migration Strategy

#### 10.1 SwiftData Schema Migrations

SwiftData supports schema versioning and migrations. Here's how to handle future changes:

##### 10.1.1 Schema Versioning

```swift
// Define schema versions
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [MyFilm.self, CachedIMDBFilm.self]
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [MyFilm.self, CachedIMDBFilm.self]
    }
}
```

##### 10.1.2 Migration Plans

```swift
enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            // Custom migration logic here
            // e.g., populate new fields with default values
        }
    )
}
```

#### 10.2 CloudKit Schema Evolution

CloudKit requires careful planning for schema changes:

##### 10.2.1 Safe Changes (Backward Compatible)

- **Adding optional properties** - Safe, older versions ignore new fields
- **Adding new record types** - Safe, doesn't affect existing data
- **Adding indexes** - Safe, improves query performance

Example:

```swift
// Safe to add optional property
@Model
final class MyFilm {
    // Existing properties...
    
    // New in v2 - optional with default
    var tags: [String]? = nil  // Safe addition
}
```

##### 10.2.2 Risky Changes (Require Migration)

- **Removing properties** - Data loss risk
- **Changing property types** - Compatibility issues
- **Making optional properties required** - Older app versions will crash
- **Renaming properties** - Treated as remove + add

##### 10.2.3 Migration Strategies for Breaking Changes

**Strategy 1: Dual-Write Pattern**

```swift
@Model
final class MyFilm {
    // Keep old property for compatibility
    @available(*, deprecated, message: "Use formattedRating")
    var myRating: Int?
    
    // New property with better structure
    var formattedRating: Rating? {
        didSet {
            // Sync with old property for compatibility
            myRating = formattedRating?.value
        }
    }
}

struct Rating: Codable {
    let value: Int
    let scale: Int
    let comment: String?
}
```

**Strategy 2: Version-Specific Models**

```swift
// Use different models based on app version
if appVersion >= "2.0" {
    // Use new model structure
} else {
    // Use legacy model
}
```

#### 10.3 Best Practices for Future-Proof Design

##### 10.3.1 Design Principles

1. **Always use optional properties for new fields**
2. **Never remove properties in first 6 months**
3. **Use computed properties for transformations**
4. **Version your data models explicitly**

##### 10.3.2 Pre-Migration Checklist

```swift
// Add to your MyFilm model
var schemaVersion: Int = 1  // Track schema version per record

// Add migration helper
extension MyFilm {
    func migrateIfNeeded() {
        switch schemaVersion {
        case 1:
            // Migrate from v1 to v2
            migrateToV2()
        case 2:
            // Already on v2
            break
        default:
            // Unknown version
            break
        }
    }
}
```

##### 10.3.3 CloudKit Development vs Production

1. **Development Environment**
   - Test all migrations thoroughly
   - Use separate CloudKit container
   - Reset development data freely

2. **Production Deployment**
   - Deploy schema changes first
   - Wait for user adoption (monitor analytics)
   - Then deploy code that uses new fields
   - Keep backward compatibility for 2-3 versions

#### 10.4 Emergency Recovery

##### 10.4.1 Rollback Strategy

```swift
// Keep migration reversible
extension MigrationPlan {
    static func rollbackV2ToV1(context: ModelContext) {
        // Reverse the migration if needed
    }
}
```

##### 10.4.2 Data Recovery

- Export user data before major migrations
- Implement local backup before sync
- CloudKit maintains some version history

#### 10.5 Testing Migration Scenarios

1. **Unit Tests**

```swift
func testMigrationFromV1ToV2() {
    // Create v1 data
    // Run migration
    // Verify v2 data integrity
}
```

2. **Integration Tests**

- Test with old app version + new CloudKit schema
- Test with new app version + old CloudKit data
- Test simultaneous use of different versions

3. **Manual Testing**

- Install old version, create data
- Update to new version, verify migration
- Check sync between old and new versions

### 11. Future Enhancements

- Selective sync (choose which collections to sync)
- Sync preferences and settings
- Share collections with family members
- Collaborative features (shared watchlists)

## References

- [SwiftData CloudKit Integration](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices)
- [CloudKit Best Practices](https://developer.apple.com/documentation/cloudkit/designing_and_creating_a_cloudkit_database)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
