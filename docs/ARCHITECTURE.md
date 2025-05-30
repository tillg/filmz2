# ARCHITECTURE

[TOC]

## Structure

The main elemenst of our application:

- ImdbSearchcService
- MyFilmsStore: The service that stores my films locally (or where ever).
- UI:
  - Search: The window in which a user searches for films. Mainly contains a search entry, some switches for filtering and sorting and the list of IMDB films that the search returned.
    - ImdbFilm: The details of a film from the search.
  - My Filmz: The list of films I have stored (both, the ones I plan to see and the ones I saw).
  - My Film Detail: Viewing and editing the details of a Film: Wether I saw and liked it, for which audience I would recommend it...

## Services

### ImdbSearchService

Allows us to search films in the OMDb API. We call it _IMDB_ nevertheless, because it returns IMDB type information about the movies, including the IMDB ID.

#### Technical

The OMDB API is located at the [OMDb API documentation](https://www.omdbapi.com). For data requests (i.e. search requests) we use `http://www.omdbapi.com/?apikey=[yourkey]&`. For requesting posters we use `http://img.omdbapi.com/?apikey=[yourkey]&`.

When searching we get a list of films within a JSON. An example would be:

```JSON
{
  "Title": "Mission: Impossible - The Final Reckoning",
  "Year": "2025",
  "Rated": "N/A",
  "Released": "23 May 2025",
  "Runtime": "169 min",
  "Genre": "Action, Adventure, Thriller",
  "Director": "Christopher McQuarrie",
  "Writer": "Bruce Geller, Erik Jendresen, Christopher McQuarrie",
  "Actors": "Vanessa Kirby, Tom Cruise, Hayley Atwell",
  "Plot": "Our lives are the sum of our choices. Tom Cruise is Ethan Hunt in Mission: Impossible - The Final Reckoning.",
  "Language": "English",
  "Country": "United States, United Kingdom",
  "Awards": "1 nomination total",
  "Poster": "https://m.media-amazon.com/images/M/MV5BZGQ5NGEyYTItMjNiMi00Y2EwLTkzOWItMjc5YjJiMjMyNTI0XkEyXkFqcGc@._V1_SX300.jpg",
  "Ratings": [{ "Source": "Rotten Tomatoes", "Value": "79%" }],
  "Metascore": "N/A",
  "imdbRating": "N/A",
  "imdbVotes": "N/A",
  "imdbID": "tt9603208",
  "Type": "movie",
  "DVD": "N/A",
  "BoxOffice": "N/A",
  "Production": "N/A",
  "Website": "N/A",
  "Response": "True"
}
```

See the [OMDb API example JSON file](OMDb_API_example.json).
Note: Not all the fields are relevant to us.

The description of the search parameters is available at [OMDb API search parameters](https://www.omdbapi.com/#parameters).

## UI Views

### IMDBFilmDetailView

A comprehensive detail view for displaying film information from the OMDb API. Follows MVVM architecture with proper separation of concerns.

**Components:**

- Poster display with AsyncImage and fallback
- Title and metadata sections
- Ratings display using RatingPills component
- Genre display using GenrePills component
- Expandable plot description
- Cast and crew information

**Architecture:**

- Uses IMDBFilmDetailViewModel for business logic
- Reactive UI updates with @StateObject and @Published
- Reusable pill components for consistent styling

## UI Components

### Pills System

A comprehensive system of reusable pill-shaped UI components for consistent data presentation across the app.

#### GenrePill & GenrePills

**Purpose:** Display film genres in a visually appealing, pill-shaped format.

**Components:**

- `GenrePill`: Single genre pill with customizable styling
- `GenrePills`: Collection of genre pills with flexible layout and "show more" functionality

**Features:**

- Multiple style presets (default, outlined, compact, neutral)
- Automatic wrapping to multiple lines
- Show more/less functionality for large lists
- Empty state handling
- Reactive updates when genre data changes

**Styles Available:**

- Default: Blue background with blue text
- Outlined: Clear background with blue border
- Compact: Smaller padding and font size
- Neutral: Gray background with primary text

#### RatingPill & RatingPills

**Purpose:** Display film ratings from various sources (IMDB, Rotten Tomatoes, Metacritic).

**Components:**

- `RatingPill`: Single rating with icon and value
- `RatingPills`: Collection of ratings with layout options

**Features:**

- Icon + text layout with source-specific colors
- Multiple layout options (horizontal, vertical, flexible)
- Multiple style presets (default, compact, outlined, prominent)
- Automatic color coding by rating source
- Empty state handling

**Layout Options:**

- Horizontal: Pills in a single row
- Vertical: Pills stacked vertically
- Flexible: Pills wrap to multiple lines as needed

**Styles Available:**

- Default: Standard size with background
- Compact: Smaller for condensed layouts
- Outlined: Border instead of background
- Prominent: Larger for emphasis

#### Component Architecture

**Extensibility:** The component system is designed for easy expansion:

- Consistent naming patterns (`ComponentName` + `ComponentNames`)
- Style-based configuration systems
- Reusable layout patterns
- Preview support for development

**Future Components:** The structure accommodates:

- Button components
- Card components
- Input components
- Any other reusable UI elements

**Component Library:** A centralized showcase (`ComponentLibrary.swift`) provides:

- Living style guide
- Component documentation
- Interactive examples
- Development reference
