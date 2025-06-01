# DOCUMENTATION INDEX

This directory and its subdirectories contain the project documentation. It should help new developers to onboard as well as our AI assistants.

[TOC]

## Functional scope

Filmz2 is an App to maintain films, movies and shows: The ones I saw, whether I liked them or not. The ones I was recommended, including for which audience.

### Current Features

- **Movie Search**: Search for movies by title using the OMDb API
- **Film Details**: View comprehensive information about any movie
- **Tab Navigation**: Easy switching between Search and Collection views

## Core Documentation

Best read in the following order:

- [Data Structures](DATA_STRUCTURES.md) - explains the main entities we deal with
- [Glossary](GLOSSARY.md) - explains the words we use from our film domain
- [Architecture](ARCHITECTURE.md) - describes the moving parts of our application
- [Coding Guidelines](CODING_GUIDELINES.md) - development standards and definition of done

## Feature Documentation

- [IMDB Film Detail View](features/2025-05-30-imdb-film-detail-view.md) - comprehensive feature specification with UI, testing, and requirements
- [OMDB Search Service](features/2025-05-30-omdb-search-service.md) - API service documentation for movie search functionality
- [Movie Search](features/2025-06-01-movie-search.md) - complete search interface with debouncing, pagination, and error handling

## Architecture Decision Records (ADRs)

- [ADR-001: Use UUIDs for Entity Identifiers](decisions/ADR-001-use-uuids-for_ids.md)
- [ADR-002: Use Mermaid for Diagrams](decisions/ADR-002-use-mermaid-for-diagrams.md)

## Templates

- [Feature Template](FEATURE_TEMPLATE.md) - template for documenting new features
- [ADR Template](decisions/ADR_TEMPLATE.md) - template for documenting architectural decisions
- [ADR Template (Bare)](decisions/ADR_TEMPLATE_BARE.md) - minimal ADR template
- [ADR Template (Bare Minimal)](decisions/ADR_TEMPLATE_BARE_MINIMAL.md) - ultra-minimal ADR template

## API Documentation

- [OMDb API Example](OMDb_API_example.json) - sample response from the OMDb API for reference
- [API Setup Guide](API_SETUP.md) - instructions for obtaining and configuring OMDb API access

## Testing

The project includes comprehensive test coverage:

- **Unit Tests**: MovieSearchViewModelTests, IMDBFilmDetailViewModelTests, OMDBSearchServiceTests
- **UI Tests**: MovieSearchUITests covering search interaction, navigation, and edge cases

## Getting Started

1. Clone the repository
2. Open `filmz2.xcodeproj` in Xcode
3. Build and run on iPhone 16 simulator
4. The API key is already configured in `filmz2/Config/APIKeys.swift`
