# ARCHITECTURE

[TOC]

## Overview

Filmz2 is a movie collection management app built with SwiftUI and SwiftData. It allows users to search for movies using the OMDb API, view detailed information, and maintain a personal collection with ratings, watch status, and notes.

### Key Features

- Movie search with real-time results from OMDb API
- Detailed film information display
- Personal collection management with automatic iCloud sync
- Offline capability with intelligent caching
- Watch status and personal ratings tracking
- Clean, native iOS/macOS interface
- Seamless multi-device synchronization via CloudKit

## System Overview

```mermaid
C4Context
    title Filmz2 System Context Diagram

    Person(user, "Movie Enthusiast", "A person who wants to search and track movies")

    System_Boundary(filmz2, "Filmz2 App") {
        Container(app, "iOS/macOS App", "SwiftUI", "Movie search and collection management")
    }

    System_Ext(omdb, "OMDb API", "External movie database API")
    System_Ext(icloud, "iCloud/CloudKit", "Apple's cloud sync service")

    Rel(user, app, "Uses", "Search movies, view details, manage collection")
    Rel(app, omdb, "Queries", "HTTPS/JSON")
    Rel(app, icloud, "Syncs", "CloudKit private database")
    Rel_Back(icloud, app, "Syncs", "Automatic sync across devices")

    UpdateRelStyle(user, app, $offsetX="-40", $offsetY="-10")
    UpdateRelStyle(app, icloud, $offsetX="20", $offsetY="-10")

    UpdateLayoutConfig($c4ShapeInRow="2", $c4BoundaryInRow="1")
```

## Core Architecture Pattern: ID-Only with Cached Metadata

Filmz2 uses an ID-only architecture pattern where user data (MyFilm) only stores the IMDB ID reference, while film metadata is cached separately using IMDBFilm as both API response and persistent cache model. This provides several key benefits:

### Benefits

- **No Data Duplication**: Each film's metadata is stored exactly once
- **Offline Access**: Cached data enables full functionality without internet
- **Smart API Usage**: Cache-first approach minimizes API calls
- **Clean Separation**: User data is clearly separated from movie metadata
- **Future-Ready**: Enables features like shared collections or social features
- **Efficient Storage**: Smaller footprint for user collections

### How It Works

1. User adds a film to collection → MyFilm created with just imdbID
2. Film details needed → Check cached IMDBFilm first
3. Cache miss or stale → Fetch from OMDb API, decode to IMDBFilm, and cache
4. Display film → Combine MyFilm (user data) + IMDBFilm (metadata)

```mermaid
sequenceDiagram
    participant User
    participant MyFilm
    participant Cache
    participant API

    User->>MyFilm: Add to collection (imdbID only)
    MyFilm->>MyFilm: Store user data

    User->>MyFilm: View film details
    MyFilm->>Cache: Request metadata by imdbID

    alt Cache Hit & Fresh
        Cache-->>MyFilm: Return cached metadata
    else Cache Miss or Stale
        Cache->>API: Fetch film details
        API-->>Cache: Return metadata
        Cache->>Cache: Store for future use
        Cache-->>MyFilm: Return metadata
    end

    MyFilm-->>User: Display combined data
```

## High-Level Architecture

The app follows a layered architecture with clear separation of concerns:

```mermaid
graph TB
    subgraph "UI Layer"
        CV[ContentView]
        MSV[MovieSearchView]
        MSVM[MovieSearchViewModel]
        FC[FilmCell]
        MSRC[MovieSearchResultCell]
        MFC[MyFilmCell]
        IFDV[IMDBFilmDetailView]
        IFDVM[IMDBFilmDetailViewModel]
        CollV[CollectionView]
        MFDV[MyFilmDetailView]
    end

    subgraph "Service Layer"
        OMDB[OMDBSearchService]
        MFS[MyFilmsStore]
    end

    subgraph "Data Layer"
        MF[MyFilm - User Data]
        IF[IMDBFilm - API Response & Cache]
    end

    subgraph "External"
        API[OMDb API]
        LS[SwiftData Storage]
        CK[CloudKit]
    end

    CV --> MSV
    CV --> CollV
    MSV --> MSVM
    MSV --> FC
    FC --> MSRC
    FC --> MFC
    CollV --> MFC
    MSVM --> OMDB
    FC --> IFDV
    FC --> MFDV
    IFDV --> IFDVM
    OMDB --> API
    OMDB --> IF
    MFS --> MF
    MF --> LS
    MF --> CK
    IF --> LS
    CK --> MF

    classDef ui fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef service fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef data fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    classDef external fill:#f3e5f5,stroke:#4a148c,stroke-width:2px

    class CV,MSV,MSVM,FC,MSRC,MFC,IFDV,IFDVM,CollV,MFDV ui
    class OMDB,MFS service
    class MF,IF data
    class API,LS,CK external
```

### Architecture Layers

1. **UI Layer**: SwiftUI views and view models implementing MVVM pattern
2. **Service Layer**: Business logic and API communication
3. **Data Layer**: Models and persistence using SwiftData
4. **External Layer**: Third-party services and system storage

## Data Model Architecture

### Model Relationships

```mermaid
erDiagram
    MyFilm ||--o| IMDBFilm : "references via imdbID"
    MyFilm {
        uuid id PK "No unique constraint for CloudKit"
        string imdbID "No unique constraint for CloudKit"
        int myRating
        bool watched "Default: false"
        date dateWatched
        string notes
        enum audience
        string recommendedBy
        date dateAdded "Default: Date()"
    }

    IMDBFilm {
        string imdbID "No unique constraint for CloudKit"
        string title
        string year
        string rated
        string actors
        string plot
        string poster
        array ratings
        string imdbRating
        date lastFetched
        int dataVersion
    }

    OMDBSearchItem {
        string title
        string year
        string imdbID
        string type
        string poster
    }

    SearchResult ||--o{ IMDBFilm : contains
    OMDBSearchResponse ||--o{ OMDBSearchItem : contains
    OMDBSearchItem ||--|| IMDBFilm : "converts to"
```

### Key Models

1. **MyFilm**: Stores user-specific data (ratings, notes, watch status) - Synced via CloudKit
2. **IMDBFilm**: Unified model serving as both API response decoder and persistent cache - Local only
3. **OMDBSearchItem**: Search result from API (converted to IMDBFilm for detail views)

### Model Consolidation Architecture

**Design Decision**: IMDBFilm serves dual purposes as both API response decoder and persistent cache model.

**Benefits of Consolidation**:

- **Simplified Architecture**: Single model instead of separate API and cache models
- **No Data Conversion**: Eliminates transformation between CachedIMDBFilm and IMDBFilm
- **Unified Lifecycle**: API responses directly cached without intermediate steps
- **CloudKit Compatible**: No unique constraints, manual uniqueness handling in CacheManager
- **Reduced Complexity**: Fewer model types to maintain and test

**Implementation Details**:

- **SwiftData @Model**: IMDBFilm is a SwiftData-managed class for persistence
- **Codable Conformance**: Custom encode/decode for API communication
- **Cache Metadata**: Built-in lastFetched and dataVersion fields for staleness detection
- **Manual Uniqueness**: CacheManager handles duplicate prevention (CloudKit requirement)

### CloudKit Considerations

All models must be CloudKit-compatible:

- No unique constraints allowed
- All non-optional properties must have default values
- Single model container for simplicity

## Navigation Architecture

### Tab-Based Navigation Structure

```mermaid
graph TB
    subgraph "App Structure"
        App[filmz2App]
        CV[ContentView]
        TV[TabView]
    end

    subgraph "Tab 1: Collection"
        CT[Collection Tab - Default]
        CollV[CollectionView]
        MFDV[MyFilmDetailView]
    end

    subgraph "Tab 2: Search"
        ST[Search Tab]
        MSV[MovieSearchView]
        IFDV1[IMDBFilmDetailView]
    end

    subgraph "Tab 3: Settings"
        SetT[Settings Tab]
        SetV[SettingsView]
        AV[AboutView]
    end

    App --> CV
    CV --> TV
    TV --> CT
    TV --> ST
    TV --> SetT

    CT --> CollV
    CollV -.navigate.-> MFDV

    ST --> MSV
    MSV -.navigate.-> IFDV1

    SetT --> SetV
    SetV -.navigate.-> AV

    style CT fill:#4caf50
    style CollV fill:#81c784
```

### Navigation Flow

```mermaid
sequenceDiagram
    participant User
    participant TabView
    participant CollectionView
    participant MovieSearchView
    participant FilmCell
    participant DetailView

    User->>TabView: Launch App
    TabView->>CollectionView: Default to Collection Tab

    User->>TabView: Switch to Search
    TabView->>MovieSearchView: Show search interface

    User->>MovieSearchView: Search "Batman"
    MovieSearchView->>MovieSearchView: Display Results

    Note over FilmCell: Smart wrapper checks status
    alt Film NOT in collection
        User->>FilmCell: Tap result
        FilmCell->>DetailView: Navigate to IMDBFilmDetailView
        User->>DetailView: Add to Collection
    else Film IN collection
        User->>FilmCell: Tap result
        FilmCell->>DetailView: Navigate to MyFilmDetailView
    end
```

## Services

### OMDBSearchService

The core service for interacting with the OMDb API with intelligent caching.

**Key Features:**

- Search films by title with pagination
- Get detailed film information by IMDB ID
- Persistent caching using IMDBFilm model
- Cache-first approach with 30-day freshness
- Automatic retry and error handling
- In-memory response caching

**Architecture:**

```mermaid
sequenceDiagram
    participant VM as ViewModel
    participant OS as OMDBSearchService
    participant Cache as CacheManager
    participant Mem as In-Memory Cache
    participant API as OMDb API

    VM->>OS: searchFilms("Batman")
    OS->>Mem: Check memory cache

    alt Memory Hit
        Mem-->>OS: Return cached response
    else Memory Miss
        OS->>API: GET /s=Batman
        API-->>OS: JSON Response
        OS->>Mem: Store in memory
    end

    OS-->>VM: SearchResult

    VM->>OS: getFilm(imdbID)
    OS->>Cache: Check persistent cache

    alt Cache Fresh
        Cache-->>OS: Return IMDBFilm
    else Cache Stale/Miss
        OS->>API: GET /i=imdbID
        API-->>OS: Film Details (decoded to IMDBFilm)
        OS->>Cache: Cache IMDBFilm
    end

    OS-->>VM: IMDBFilm
```

### MyFilmsStore

Manages the user's personal film collection with reactive updates.

**Key Features:**

- CRUD operations for user's collection
- Real-time statistics (total, watched, unwatched)
- Duplicate prevention
- SwiftUI integration with @Published
- Automatic UI updates

## Swift Concurrency and Sendable Compliance

### The Challenge

Swift 6's strict concurrency model introduces Sendable requirements that create challenges when working with SwiftData models. The core issue is that SwiftData's `@Model` classes are inherently non-Sendable because they:

- Contain mutable state managed by SwiftData
- Use internal synchronization mechanisms
- Cannot be safely passed across actor boundaries without explicit handling

### Our Solution: ModelActor Pattern

Filmz2 uses SwiftData's `ModelActor` pattern to handle all database operations safely across concurrent environments. The `ModelActor` protocol provides a dedicated actor context for performing SwiftData operations on background queues while maintaining thread safety.

### What is ModelActor?

`ModelActor` is a protocol that conforms to Swift's `Actor` protocol, providing isolated access to a `ModelContext`. When you create a custom actor that conforms to `ModelActor`, SwiftData automatically provides the necessary infrastructure for safe concurrent database operations.

### Key Features

- **Automatic ModelContext Management**: SwiftData automatically creates and manages a `ModelContext` instance for your actor
- **Thread Safety**: All operations are automatically serialized, preventing data races
- **Background Processing**: Perfect for performing heavy database operations without blocking the main thread

### Implementation

```swift
@ModelActor
actor FilmCacheActor {
    func fetchFilm(imdbID: String) throws -> IMDBFilm? {
        let descriptor = FetchDescriptor<IMDBFilm>(
            predicate: #Predicate { $0.imdbID == imdbID }
        )
        return try modelContext.fetch(descriptor).first
    }

    func saveFilm(_ film: IMDBFilm) throws {
        modelContext.insert(film)
        try modelContext.save()
    }

    func fetchAllFilms() throws -> [IMDBFilm] {
        let descriptor = FetchDescriptor<IMDBFilm>()
        return try modelContext.fetch(descriptor)
    }
}
```

### Usage Pattern

```swift
// Create the actor instance
let cacheActor = FilmCacheActor(modelContainer: container)

// Use in service layer
class OMDBSearchService {
    private let cacheActor: FilmCacheActor

    func getFilm(byID: String) async throws -> IMDBFilm {
        // Check actor-managed cache first
        if let cached = try await cacheActor.fetchFilm(imdbID: byID) {
            return cached
        }

        // Fetch from API
        let film = try await fetchFromAPI(byID)

        // Save through actor
        try await cacheActor.saveFilm(film)

        return film
    }
}
```

### Benefits

- **Best Practice Compliance**: Follows Apple's recommended SwiftData concurrency patterns
- **True Thread Safety**: Provides genuine actor isolation without compiler workarounds
- **Automatic Isolation**: No need to manually manage thread safety
- **Simplified Error Handling**: Clean async/await error handling
- **Better Performance**: Background operations don't block UI
- **Memory Management**: SwiftData handles ModelContext lifecycle automatically
- **Scalability**: Handles background operations efficiently as the app grows
- **Clean Architecture**: Separates database concerns from service logic

## UI Component Architecture

### Component Hierarchy

```mermaid
graph TD
    subgraph "Reusable Components"
        FPS[FilmPosterSection]
        FIR[FilmInfoRow]
        FMS[FilmMetadataSection]
        EP[ExpandablePlot]
        FCCS[FilmCastAndCrewSection]

        subgraph "Pills System"
            GP[GenrePill]
            GPS[GenrePills]
            RP[RatingPill]
            RPS[RatingPills]
        end

        subgraph "Ratings"
            IRV[IMDBRatingView]
            RTV[RottenTomatoesRatingView]
            MRV[MyRatingView]
            RR[RatingsRow]
        end

        ACB[AddToCollectionButton]
        SRV[StarRatingView]
    end

    subgraph "Cell Components"
        FC[FilmCell - Smart Wrapper]
        MSRC[MovieSearchResultCell]
        MFC[MyFilmCell]

        FC --> MSRC
        FC --> MFC
    end
```

### FilmCell - The Smart Wrapper Pattern

A unified component that intelligently displays films based on collection status:

```text
FilmCell (Wrapper Component)
  ├── Checks: Is film in user's collection?
  ├── If YES → Renders: MyFilmCell
  │   └── Shows: Personal data (rating, watched status)
  │   └── Navigates to: MyFilmDetailView
  └── If NO → Renders: MovieSearchResultCell
      └── Shows: Basic info + "Add to Collection" button
      └── Navigates to: IMDBFilmDetailView
```

## State Management

### Reactive State Flow

```mermaid
stateDiagram-v2
    [*] --> Initial: App Launch

    state "Collection State" as CS {
        [*] --> Empty: No films
        Empty --> HasFilms: Add film
        HasFilms --> Empty: Remove all
        HasFilms --> HasFilms: Add/Remove/Update
    }

    state "Search State" as SS {
        [*] --> Idle
        Idle --> Searching: Type query
        Searching --> Loading: Debounce
        Loading --> Results: Success
        Loading --> Error: Failure
        Results --> Loading: Load more
        Error --> Searching: Retry
    }

    state "Film Cell State" as FCS {
        [*] --> CheckStatus: Render
        CheckStatus --> NotInCollection: Not found
        CheckStatus --> InCollection: Found
        NotInCollection --> InCollection: Add
        InCollection --> NotInCollection: Remove
    }
```

### Data Flow

1. **User Action** → View captures input
2. **View** → Updates ViewModel via binding
3. **ViewModel** → Calls Service layer
4. **Service** → Updates Model/Makes API call
5. **Model** → Notifies observers
6. **View** → Re-renders with new data

## API Integration

### OMDb API Details

**Base URL**: `http://www.omdbapi.com/`  
**Poster URL**: `http://img.omdbapi.com/`

**Key Endpoints:**

- Search: `/?s={title}&page={page}`
- Details: `/?i={imdbID}`
- By Title: `/?t={title}&y={year}`

**Error Handling:**

```mermaid
graph TD
    Start([API Call]) --> Request{Make Request}
    Request -->|Success| Decode{Decode JSON}
    Request -->|Network Error| NetErr[NetworkError]

    Decode -->|Success| CheckResp{Check Response}
    Decode -->|Failure| DecErr[DecodingError]

    CheckResp -->|"True"| Success[Return Data]
    CheckResp -->|"False"| CheckErr{Check Error Message}

    CheckErr -->|"Invalid API key"| APIErr[InvalidAPIKey]
    CheckErr -->|"Movie not found"| NotFound[MovieNotFound]
    CheckErr -->|"Request limit"| Limit[DailyLimitExceeded]
    CheckErr -->|Other| Unknown[UnknownError]
```

## CloudKit Integration and iCloud Requirement

Filmz2 **requires** iCloud sign-in as a core architectural decision. This approach, inspired by the original filmz project, eliminates complexity and provides a seamless user experience.

### Key Principles

1. **Mandatory iCloud**: Users must be signed into iCloud to use the app
2. **Automatic Sync**: No manual sync controls or status indicators
3. **Zero Configuration**: Works automatically across all devices
4. **Seamless Experience**: No sync UI - the app just works

### Architecture Benefits

- **Simplicity**: No need to handle offline/online states differently
- **Consistency**: All devices always have the same data
- **Reliability**: Apple handles sync conflicts automatically
- **Privacy**: Data stored in user's private CloudKit database

### Implementation Details

```swift
// SwiftData configuration with CloudKit
let syncedConfiguration = ModelConfiguration(
    schema: syncedSchema,
    isStoredInMemoryOnly: false,
    cloudKitDatabase: .private("iCloud.com.grtnr.filmz2")
)
```

The app uses separate model configurations:

- **MyFilm**: Synced via CloudKit (user's collection data)
- **IMDBFilm**: Local only (movie metadata cache and API response model)

### iCloud Check Flow

```mermaid
graph TD
    Start[App Launch] --> Check{iCloud Signed In?}
    Check -->|Yes| Main[Show Main App]
    Check -->|No| Required[Show iCloud Required Screen]
    Required --> Settings[Open Settings Button]
    Settings --> System[System Settings]
    System --> SignIn[User Signs In]
    SignIn --> Check
```

## CloudKit Access and Configuration

### Prerequisites and Requirements

#### User Requirements

1. **iCloud Account**: User must be signed into iCloud on their device
2. **iCloud Drive**: Must be enabled in device settings
3. **Storage Quota**: Sufficient iCloud storage available (MyFilm data is minimal ~1KB per film)
4. **Network Access**: Initial sync requires internet connection

#### Developer Requirements

1. **Apple Developer Account**: Required for CloudKit capabilities
2. **Provisioning Profiles**: Must include CloudKit entitlements
3. **Bundle Identifier**: Must match CloudKit container ID

### Project Configuration

#### 1. Xcode Capabilities

Enable the following capabilities in your app target:

1. **iCloud**

   - ✓ CloudKit
   - ✓ Use default container or specify custom

2. **Push Notifications** (Required for CloudKit sync)
   - Automatically enabled with CloudKit

#### 2. Entitlements File

The `filmz2.entitlements` file must contain:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Push notifications for CloudKit sync -->
    <key>aps-environment</key>
    <string>development</string>

    <!-- CloudKit container identifier -->
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.grtnr.filmz2</string>
    </array>

    <!-- Enable CloudKit services -->
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
</dict>
</plist>
```

#### 3. Info.plist Configuration

Add usage descriptions for user transparency:

```xml
<key>NSUbiquitousContainers</key>
<dict>
    <key>iCloud.com.grtnr.filmz2</key>
    <dict>
        <key>NSUbiquitousContainerName</key>
        <string>Filmz2 Collection</string>
        <key>NSUbiquitousContainerIsDocumentScopePublic</key>
        <false/>
    </dict>
</dict>
```

### CloudKit Dashboard Configuration

#### 1. Container Setup

1. Navigate to [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard)
2. Select or create container: `iCloud.com.grtnr.filmz2`
3. Environment: Development → Production promotion flow

#### 2. Record Types

SwiftData automatically creates record types, but understanding them helps with debugging:

- **CD_MyFilm**: User's film collection data
  - Fields map to MyFilm properties
  - Indexed on: modifiedAt, recordName

#### 3. Security Roles

Default security for private database:

- **Owner**: Read/Write (automatic for user's own data)
- **No public access**: All data in private database

### Access Control and Error Handling

#### iCloud Status Checking

```swift
// Check iCloud availability
func checkiCloudStatus() -> Bool {
    if FileManager.default.ubiquityIdentityToken != nil {
        return true // iCloud is available
    } else {
        return false // User not signed in
    }
}
```

#### Common Access Errors

1. **CKError.notAuthenticated**

   - User not signed into iCloud
   - Solution: Show ICloudRequiredView

2. **CKError.quotaExceeded**

   - User's iCloud storage is full
   - Solution: Alert user to manage storage

3. **CKError.networkUnavailable**

   - No internet connection
   - Solution: Queue changes for later sync

4. **CKError.serverResponseLost**
   - Sync interrupted
   - Solution: Automatic retry by SwiftData

### Privacy and Data Access

#### Data Location

- **Private Database**: All user data stored in their private CloudKit database
- **No Shared Database**: No data sharing between users
- **No Public Database**: No publicly accessible data

#### Data Encryption

- **In Transit**: TLS encryption for all CloudKit communication
- **At Rest**: Encrypted on Apple's servers
- **End-to-End**: User's data accessible only with their iCloud credentials

#### GDPR and Privacy Compliance

- **Data Ownership**: User owns all their data
- **Data Portability**: Export functionality available
- **Right to Delete**: Deleting app removes all CloudKit data
- **No Analytics**: No user data collected by developer

### Troubleshooting Common Issues

#### 1. "Sign in to iCloud" Despite Being Signed In

**Cause**: App-specific iCloud permissions
**Solution**:

- Settings → Apple ID → iCloud → Apps Using iCloud → Enable Filmz2

#### 2. Sync Not Working

**Checklist**:

- ✓ iCloud Drive enabled
- ✓ Sufficient storage available
- ✓ Network connection active
- ✓ Not in Low Power Mode
- ✓ Background App Refresh enabled

#### 3. Development vs Production

**Development**:

- Separate CloudKit database
- Reset development data: CloudKit Dashboard → Reset Development Environment

**Production**:

- Deploy schema to production before app release
- No reset available - careful with schema changes

### Testing CloudKit Access

#### Unit Tests

```swift
// Mock iCloud availability
class MockFileManager: FileManager {
    var mockUbiquityToken: Any? = "mock-token"

    override var ubiquityIdentityToken: Any? {
        return mockUbiquityToken
    }
}
```

#### UI Tests

```swift
// Test iCloud required flow
func testICloudRequiredView() {
    // Mock no iCloud
    // Verify ICloudRequiredView appears
    // Test "Open Settings" button
}
```

### CloudKit Design Decisions

1. **Mandatory iCloud**: Simplifies architecture by eliminating sync state management
2. **Private Database Only**: Ensures user privacy and automatic authentication
3. **No Sync UI**: Follows the philosophy that sync should be invisible to users
4. **Single Model Container**: All models in one container for simplicity, even though only MyFilm syncs

## Performance Considerations

### Caching Strategy

1. **In-Memory Cache**: Immediate response for repeated searches
2. **Persistent Cache**: 30-day freshness for offline access
3. **Lazy Loading**: Images loaded asynchronously
4. **Debounced Search**: 500ms delay prevents excessive API calls

### SwiftData Optimization

- Efficient queries using predicates
- Batch operations where possible
- Minimal model complexity for MyFilm
- Separate cache model for metadata

## Testing Architecture

### Test Structure

```text
filmz2Tests/
├── Services/
│   ├── OMDBSearchServiceTests
│   └── MyFilmsManagerTests
├── ViewModels/
│   ├── MovieSearchViewModelTests
│   └── IMDBFilmDetailViewModelTests
└── UI/
    └── MovieSearchUITests
```

### Testing Approach

- Unit tests for services with mocked URLSession
- ViewModel tests with mock services
- UI tests for critical user flows
- SwiftData tests using in-memory stores

## Future Extensibility

The architecture supports future enhancements:

1. **Social Features**: ID-only pattern enables sharing collections
2. **Multiple Lists**: Extend MyFilm with list relationships
3. **Recommendations**: Add recommendation engine using cached data
4. **Export/Import**: Simple with separated user data
5. **Analytics**: Track viewing patterns from MyFilm data

## Summary

Filmz2's architecture prioritizes:

- **Separation of Concerns**: Clear layer boundaries
- **Offline First**: Comprehensive caching strategy
- **User Experience**: Reactive UI with immediate feedback
- **Maintainability**: Consistent patterns and components
- **Performance**: Efficient data storage and API usage
- **Seamless Sync**: Mandatory iCloud with automatic CloudKit synchronization

The ID-only pattern with cached metadata provides an elegant solution for managing user collections while maintaining data integrity and enabling offline functionality. The mandatory iCloud requirement ensures a seamless, zero-configuration experience across all user devices.
