# GLOSSARY

Key entities and terms used throughout the Filmz2 application.

[TOC]

## Core Entities

- **Film**: Everything that can be watched, in a movie theatre or online. Can be a movie, a show, a documentary...
- **MyFilm**: A film in the user's personal collection. Stores only the IMDB ID and user-specific data (rating, notes, watch status).
- **CachedIMDBFilm**: Locally cached film metadata from the OMDb API. Enables offline access and reduces API calls.
- **IMDB**: The Internet Movie Database is the reference for films. It contains every film, the year it came out, the genres, director, actors, writers, a rating from its audience (called the IMDB Rating), a link to a poster and to a preview and more. Website is [here](https://www.imdb.com/).
- **IMDB Rating**: Indicates how the audience of IMDB liked the film. 1..10.
- **My Rating**: User's personal rating for a film in their collection. 0..10 stars.
- **OMDB**: The Open Media Database. An open source inspired collection of media, mainly films. Like IMDB but not commercial. Contains similar data like IMDB.
- **OMDb API**: The OMDb API is a RESTful web service to obtain movie information, all content and images on the site are contributed and maintained by our users. It offers a free to low cost API to find movies and shows. Its result includes similar data as the IMDB, including the IMDB Id of the film.
- **Genre**: The type of story told by the film. Examples: Adventure, Crime, Action, Thriller, Drama...
- **MediaType**: Classification of content: movie, series, or episode.
- **Search Result**: A movie entry returned from a search query, containing basic info like title, year, and poster.
- **Personal Collection**: User's curated list of films they want to track, including watched status, ratings, and notes.

## Architecture Terms

- **ID-Only Pattern**: Architecture pattern where user data (MyFilm) stores only the IMDB ID reference, while film metadata is cached separately (CachedIMDBFilm). Prevents data duplication and enables future features.
- **MVVM**: Model-View-ViewModel architecture pattern. Views display UI, ViewModels contain business logic, Models represent data structures.
- **ViewModel**: Business logic layer that sits between Views and Models. Handles data formatting, state management, and user interactions.
- **Model**: Data structures that represent the core entities (e.g., IMDBFilm, MyFilm).
- **View**: SwiftUI components that handle user interface presentation.
- **SwiftData**: Apple's modern persistence framework used for storing MyFilm and CachedIMDBFilm data locally.
- **@Model**: SwiftData property wrapper that marks a class as a persistent model.
- **Component Library**: Centralized showcase system for reusable UI components, used for development and testing.
- **Environment Values**: SwiftUI's dependency injection system for passing data through the view hierarchy.
- **Persistence Layer**: The data storage layer using SwiftData for local database management.

## Collection Management

- **MyFilmsStore/MyFilmsManager**: Service that manages the user's film collection with CRUD operations and SwiftData persistence.
- **Collection View**: Main screen showing the user's personal film collection with filtering and sorting options.
- **Watched Status**: Boolean flag indicating whether the user has seen the film.
- **Date Watched**: When the user watched the film (optional).
- **AudienceType**: Enum describing who watched the film with the user: "Me alone", "Me and partner", or "Family".
- **Collection Filter**: Options to filter the collection by watched status and genres.
- **Sort Options**: Ways to order the collection: by name, year, or date added (ascending/descending).

## UI Components

- **Pills**: Pill-shaped UI components used for displaying categorized information:
  - **GenrePill**: Single pill displaying one genre
  - **GenrePills**: Collection of genre pills with flexible layout
  - **RatingPill**: Single pill displaying one rating source
  - **RatingPills**: Collection of rating pills from multiple sources
- **FilmCell**: Smart wrapper component that displays films differently based on collection status (shows MyFilmCell or MovieSearchResultCell).
- **MyFilmCell**: Cell component for films in the user's collection, showing personal data like rating and watch status.
- **MovieSearchResultCell**: Cell component for search results not in collection, with "Add to Collection" button.
- **AddToCollectionButton**: Blue circular button with + icon for adding films to personal collection.
- **StarRatingView**: Interactive component for setting personal ratings (0-10 stars).
- **RatingsRow**: Horizontal display of all available ratings (IMDB, Rotten Tomatoes, My Rating).
- **ExpandablePlot**: Text component that can expand/collapse long plot descriptions.
- **FilmPosterSection**: Reusable component for displaying movie posters with fallback handling.
- **AsyncImage**: SwiftUI component for loading and displaying images from URLs with placeholder handling.
- **FlexibleLayout**: Custom SwiftUI layout that automatically wraps content to multiple lines when needed.
- **TabView**: SwiftUI container that organizes the app into tabs (Collection, Search, Settings).

## SwiftUI Terms

- **@StateObject**: Property wrapper for creating and managing observable objects in SwiftUI.
- **@Published**: Property wrapper that announces changes to subscribers when the value changes.
- **@Bindable**: SwiftData property wrapper for creating two-way bindings to model properties.
- **@Environment**: Property wrapper for accessing environment values like modelContext.
- **@ViewBuilder**: Function builder that creates views from multiple child views.
- **Preview**: SwiftUI development feature that shows real-time UI previews in Xcode.
- **NavigationStack**: SwiftUI container for managing navigation between views.
- **Sheet**: Modal presentation style for temporary views.

## Data Handling

- **Cache Freshness**: 30-day policy for cached film data. Data older than 30 days is considered stale and refreshed.
- **Cache-First Strategy**: Always check local cache before making API calls to reduce network usage.
- **Optional Unwrapping**: Swift technique for safely handling values that might be nil.
- **Custom Decoding**: Specialized JSON decoding logic that handles API-specific cases like "N/A" values.
- **Computed Properties**: Properties that calculate their value rather than storing it.
- **Sample Data**: Predefined data structures used for testing and previews.
- **Debouncing**: Technique to delay search execution until user stops typing (500ms in our implementation).
- **Pagination**: Loading search results in pages to improve performance (10 results per page).
- **Response Caching**: Storing API responses to reduce redundant network calls.
- **ModelContext**: SwiftData's context for managing persistent objects and save operations.

## Testing Terms

- **Unit Tests**: Tests that verify individual components work correctly in isolation.
- **UI Tests**: Tests that verify user interface interactions work correctly.
- **Test Coverage**: Percentage of code that is tested by automated tests.
- **Mock Data**: Fake data used in tests to simulate real API responses.
- **In-Memory Store**: SwiftData configuration for tests that doesn't persist to disk.

## Search Features

- **Movie Search**: The primary search functionality allowing users to find movies by title.
- **Search Debouncing**: 500ms delay after typing stops before executing search to reduce API calls.
- **Search Results**: List of movies returned from a search query, displayed with posters and metadata.
- **Empty State**: UI shown when no search results are found.
- **Error State**: UI shown when search encounters an error (network, API limit, etc.).
- **Loading State**: UI shown while search is in progress.
- **Pagination**: Automatic loading of additional results when scrolling near the bottom.

## API Terms

- **API Key**: Authentication credential required for OMDb API access.
- **Rate Limiting**: Daily request limit (1000 requests) imposed by OMDb API.
- **Search Endpoint**: API endpoint for searching movies by title (`?s=query`).
- **Detail Endpoint**: API endpoint for getting full movie details (`?i=imdbID`).
- **Response Status**: API field indicating success ("True") or failure ("False").
- **Error Messages**: Specific error strings returned by API (e.g., "Movie not found", "Invalid API key").

## Navigation

- **Main Tabs**: The three primary sections of the app:
  - **Collection Tab**: Shows user's personal film collection (default landing)
  - **Search Tab**: Movie search interface
  - **Settings Tab**: App preferences and information
- **Navigation Destination**: SwiftUI's type-safe navigation system for pushing views.
- **Dismiss**: SwiftUI environment action for closing modal presentations.

## Settings & Preferences

- **Settings View**: Screen for app preferences and configuration options.
- **About View**: Information screen showing app version, developer info, and credits.
- **Cache Management**: Options to view and clear cached film data.

## Development Tools

- **Xcode**: Apple's integrated development environment for iOS app development.
- **SwiftLint**: Tool for enforcing Swift style and conventions.
- **Markdown Linting**: Tools for checking and formatting documentation files.
- **Component Showcase**: Interactive display of UI components for development reference.
- **XcodeBuildMCP**: Tool for building and running iOS apps in simulator.
- **Combine Framework**: Apple's framework for handling asynchronous events (used for search debouncing).

## Status Indicators

- **Checkmark Icon**: Green circle with checkmark indicating a film is in the user's collection.
- **Plus Button**: Blue circular button for adding films to collection.
- **Watch Status Icons**: Visual indicators for watched/unwatched films.
- **Rating Display**: Different colored pills for IMDB (yellow), Rotten Tomatoes (red), and My Rating (red heart).

## Future Considerations

- **Shows & Series**: Current implementation treats shows as single films. Future support for seasons/episodes planned.
- **Social Features**: Potential for shared collections and friend recommendations (enabled by ID-only architecture).
- **Export/Import**: Future capability to backup and restore collections.
