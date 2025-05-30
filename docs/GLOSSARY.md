# GLOSSARY

Key entities and terms used throughout the application.

## Core Entities

- **Film**: Everything that can be watched, in a movie theatre or online. Can be a movie, a show, a documentary...
- **IMDB**: The Internet Movie Database is the reference for films. It contains every film, the year it came out, the genres, director, actors, writers, a rating from its audience (called the IMDB Rating), a link to a poster and to a preview and more. Website is [here](https://www.imdb.com/).
- **IMDB Rating**: Indicates how the audience of IMDB liked the film. 1..10.
- **OMDB**: The Open Media Database. An open source inspired collection of media, mainly films. Like IMDB but not commercial. Contains similar data like IMDB.
- **OMDb API**: The OMDb API is a RESTful web service to obtain movie information, all content and images on the site are contributed and maintained by our users. It offers a free to low cost API to find movies and shows. Its result includes similar data as the IMDB, including the IMDB Id of the film.
- **Genre**: The type of story told by the film. Examples: Adventure, Crime, Action, Thriller, Drama...

## Architecture Terms

- **MVVM**: Model-View-ViewModel architecture pattern. Views display UI, ViewModels contain business logic, Models represent data structures.
- **ViewModel**: Business logic layer that sits between Views and Models. Handles data formatting, state management, and user interactions.
- **Model**: Data structures that represent the core entities (e.g., IMDBFilm, MyFilm).
- **View**: SwiftUI components that handle user interface presentation.
- **Component Library**: Centralized showcase system for reusable UI components, used for development and testing.

## UI Components

- **Pills**: Pill-shaped UI components used for displaying categorized information:
  - **GenrePill**: Single pill displaying one genre
  - **GenrePills**: Collection of genre pills with flexible layout
  - **RatingPill**: Single pill displaying one rating source
  - **RatingPills**: Collection of rating pills from multiple sources
- **AsyncImage**: SwiftUI component for loading and displaying images from URLs with placeholder handling.
- **FlexibleLayout**: Custom SwiftUI layout that automatically wraps content to multiple lines when needed.

## SwiftUI Terms

- **@StateObject**: Property wrapper for creating and managing observable objects in SwiftUI.
- **@Published**: Property wrapper that announces changes to subscribers when the value changes.
- **@ViewBuilder**: Function builder that creates views from multiple child views.
- **Preview**: SwiftUI development feature that shows real-time UI previews in Xcode.

## Data Handling

- **Optional Unwrapping**: Swift technique for safely handling values that might be nil.
- **Custom Decoding**: Specialized JSON decoding logic that handles API-specific cases like "N/A" values.
- **Computed Properties**: Properties that calculate their value rather than storing it.
- **Sample Data**: Predefined data structures used for testing and previews.

## Testing Terms

- **Unit Tests**: Tests that verify individual components work correctly in isolation.
- **UI Tests**: Tests that verify user interface interactions work correctly.
- **Test Coverage**: Percentage of code that is tested by automated tests.
- **Mock Data**: Fake data used in tests to simulate real API responses.

## Development Tools

- **Xcode**: Apple's integrated development environment for iOS app development.
- **SwiftLint**: Tool for enforcing Swift style and conventions.
- **Markdown Linting**: Tools for checking and formatting documentation files.
- **Component Showcase**: Interactive display of UI components for development reference.
