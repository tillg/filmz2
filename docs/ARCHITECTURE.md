# ARCHITECTURE

[TOC]

## Overview

Filmz2 is a movie collection management app built with SwiftUI and SwiftData. It allows users to search for movies using the OMDb API, view detailed information, and maintain a personal collection with ratings, watch status, and notes.

### Key Features

- Movie search with real-time results from OMDb API
- Detailed film information display
- Personal collection management
- Offline capability with intelligent caching
- Watch status and personal ratings tracking
- Clean, native iOS/macOS interface

## System Overview

```mermaid
C4Context
    title Filmz2 System Context Diagram

    Person(user, "Movie Enthusiast", "A person who wants to search and track movies")

    System_Boundary(filmz2, "Filmz2 App") {
        Container(app, "iOS/macOS App", "SwiftUI", "Movie search and collection management")
    }

    System_Ext(omdb, "OMDb API", "External movie database API")

    Rel(user, app, "Uses", "Search movies, view details, manage collection")
    Rel(app, omdb, "Queries", "HTTPS/JSON")

    UpdateLayoutConfig($c4ShapeInRow="2", $c4BoundaryInRow="1")
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
        CIF[CachedIMDBFilm - Metadata Cache]
    end

    subgraph "External"
        API[OMDb API]
        LS[SwiftData Storage]
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
    OMDB --> CIF
    MFS --> MF
    MF --> LS
    CIF --> LS

    classDef ui fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef service fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef data fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    classDef external fill:#f3e5f5,stroke:#4a148c,stroke-width:2px

    class CV,MSV,MSVM,FC,MSRC,MFC,IFDV,IFDVM,CollV,MFDV ui
    class OMDB,MFS service
    class MF,CIF data
    class API,LS external
```

### Architecture Layers

1. **UI Layer**: SwiftUI views and view models implementing MVVM pattern
2. **Service Layer**: Business logic and API communication
3. **Data Layer**: Models and persistence using SwiftData
4. **External Layer**: Third-party services and system storage

## Core Architecture Pattern: ID-Only with Cached Metadata

Filmz2 uses an innovative ID-only architecture pattern where user data (MyFilm) only stores the IMDB ID reference, while film metadata is cached separately (CachedIMDBFilm). This provides several key benefits:

### Benefits

- **No Data Duplication**: Each film's metadata is stored exactly once
- **Offline Access**: Cached data enables full functionality without internet
- **Smart API Usage**: Cache-first approach minimizes API calls
- **Clean Separation**: User data is clearly separated from movie metadata
- **Future-Ready**: Enables features like shared collections or social features
- **Efficient Storage**: Smaller footprint for user collections

### How It Works

1. User adds a film to collection → MyFilm created with just imdbID
2. Film details needed → Check CachedIMDBFilm first
3. Cache miss or stale → Fetch from OMDb API and cache
4. Display film → Combine MyFilm (user data) + CachedIMDBFilm (metadata)

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

## Data Model Architecture

### Model Relationships

```mermaid
erDiagram
    MyFilm ||--o| CachedIMDBFilm : "references via imdbID"
    MyFilm {
        uuid id PK
        string imdbID UK
        int myRating
        bool watched
        date dateWatched
        string notes
        enum audience
        string recommendedBy
        date dateAdded
    }

    CachedIMDBFilm {
        string imdbID PK
        string title
        string year
        string actors
        string plot
        string poster
        string imdbRating
        date lastFetched
        int dataVersion
    }

    CachedIMDBFilm ||--|| IMDBFilm : "converts to/from"
    IMDBFilm {
        string title
        string imdbID
        string year
        string rated
        string plot
        array ratings
        string imdbRating
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
```

### Key Models

1. **MyFilm**: Stores user-specific data (ratings, notes, watch status)
2. **CachedIMDBFilm**: Persistent cache of movie metadata from API
3. **IMDBFilm**: Runtime model for displaying film details
4. **OMDBSearchItem**: Search result from API

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

## Service Layer Details

### OMDBSearchService

The core service for interacting with the OMDb API with intelligent caching.

**Key Features:**

- Search films by title with pagination
- Get detailed film information by IMDB ID
- Persistent caching using CachedIMDBFilm
- Cache-first approach with 30-day freshness
- Automatic retry and error handling
- In-memory response caching

**Architecture:**

```mermaid
sequenceDiagram
    participant VM as ViewModel
    participant OS as OMDBSearchService
    participant Cache as CachedIMDBFilm Store
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
        Cache-->>OS: Return CachedIMDBFilm
    else Cache Stale/Miss
        OS->>API: GET /i=imdbID
        API-->>OS: Film Details
        OS->>Cache: Update cache
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
  ├── If NO → Renders: MovieSearchResultCell
  │   └── Shows: Basic info + "Add to Collection" button
  │   └── Navigates to: IMDBFilmDetailView
  └── Provides: Consistent layout across both states
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

The ID-only pattern with cached metadata provides an elegant solution for managing user collections while maintaining data integrity and enabling offline functionality.
