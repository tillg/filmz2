# GLOSSARY

Key domain terms and project-specific concepts used in the Filmz2 application.

## Core Entities

- **Film**: Everything that can be watched - movies, shows, documentaries
- **MyFilm**: A film in the user's personal collection. Stores only the IMDB ID and user-specific data (rating, notes, watch status)
- **CachedIMDBFilm**: Locally cached film metadata from the OMDb API. Enables offline access and reduces API calls
- **IMDB**: The Internet Movie Database - the reference source for film information. Website: [imdb.com](https://www.imdb.com/)
- **IMDB Rating**: Audience rating from IMDB users (1-10 scale)
- **My Rating**: User's personal rating for films in their collection (0-10 stars)
- **OMDb API**: RESTful web service for movie information from [omdbapi.com](https://www.omdbapi.com/)
- **Personal Collection**: User's curated list of films with watched status, ratings, and notes

## Architecture Concepts

- **ID-Only Pattern**: Architecture where user data (MyFilm) stores only the IMDB ID reference, while film metadata is cached separately (CachedIMDBFilm). Prevents data duplication
- **Cache-First Strategy**: Always check local cache before making API calls
- **Cache Freshness**: 30-day policy for cached film data. Older data is considered stale

## Collection Management

- **Watched Status**: Whether the user has seen the film
- **AudienceType**: Who watched the film - "Me alone", "Me and partner", or "Family"
- **Collection Filter**: Options to filter by watched status and genres
- **MyFilmsStore**: Service managing the user's film collection with CRUD operations

## User Interface

- **Pills**: Pill-shaped UI components for displaying genres and ratings
- **FilmCell**: Smart component that displays films differently based on collection status
- **AddToCollectionButton**: Blue circular button with + icon for adding films
- **StarRatingView**: Interactive component for setting personal ratings (0-10 stars)

## Search & Data

- **Search Debouncing**: 500ms delay after typing stops before executing search
- **Pagination**: Loading search results in pages (10 results per page)
- **Rate Limiting**: 1000 requests/day limit on OMDb API free tier
