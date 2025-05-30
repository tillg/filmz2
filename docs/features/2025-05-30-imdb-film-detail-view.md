# Feature: IMDB Film Detail View

## Overview

A dedicated screen that displays comprehensive information about a film retrieved from the IMDB/OMDb API. The view presents film data in a visually appealing layout with the poster prominently displayed at the top, followed by organized film details.

## User Story

**As a** Filmz2 user  
**I want to** view detailed information about a film from IMDB  
**So that** I can learn about the film's cast, plot, ratings, and other metadata before deciding to add it to my personal collection

## Visual Design

### Layout Structure

```text
┌─────────────────────────┐
│       Film Poster       │
│     (AspectRatio)       │
└─────────────────────────┘
┌─────────────────────────┐
│      Film Title         │
│    (Year) • Runtime     │
└─────────────────────────┘
┌─────────────────────────┐
│      Rating Info        │
│   ⭐ IMDB • 🍅 RT        │
└─────────────────────────┘
┌─────────────────────────┐
│    Genre • Director     │
└─────────────────────────┘
┌─────────────────────────┐
│        Plot             │
│    (Description)        │
└─────────────────────────┘
┌─────────────────────────┐
│   Cast & Additional     │
│      Metadata           │
└─────────────────────────┘
```

### UI Components

1. **Film Poster**
   - Displayed as AsyncImage with fallback placeholder
   - Aspect ratio maintained (2:3 typical poster ratio)
   - Rounded corners for modern appearance
   - Loading state with placeholder

2. **Title Section**
   - Film title in large, bold typography
   - Year and runtime in secondary text style
   - Rated classification (PG, R, etc.) as badge

3. **Ratings Section**
   - IMDB rating with star icon
   - Rotten Tomatoes percentage with tomato icon
   - Metacritic score if available
   - Horizontal layout with visual icons

4. **Metadata Section**
   - Genre tags as pills
   - Director name prominently displayed
   - Release date
   - Country of origin

5. **Plot Section**
   - Plot description in readable paragraph format
   - Expandable if text is too long

6. **Cast & Crew Section**
   - Actor names in comma-separated format
   - Writer credits
   - Production information

## Technical Requirements

### Data Model

```swift
struct IMDBFilm: Codable, Identifiable {
    let id: String // imdbID
    let title: String
    let year: String
    let rated: String
    let released: String
    let runtime: String
    let genre: String
    let director: String
    let writer: String
    let actors: String
    let plot: String
    let language: String
    let country: String
    let awards: String
    let poster: String
    let ratings: [Rating]
    let metascore: String?
    let imdbRating: String?
    let imdbVotes: String?
    let imdbID: String
    let type: String
    let response: String
    
    struct Rating: Codable {
        let source: String
        let value: String
        
        enum CodingKeys: String, CodingKey {
            case source = "Source"
            case value = "Value"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case rated = "Rated"
        case released = "Released"
        case runtime = "Runtime"
        case genre = "Genre"
        case director = "Director"
        case writer = "Writer"
        case actors = "Actors"
        case plot = "Plot"
        case language = "Language"
        case country = "Country"
        case awards = "Awards"
        case poster = "Poster"
        case ratings = "Ratings"
        case metascore = "Metascore"
        case imdbRating
        case imdbVotes
        case imdbID
        case type = "Type"
        case response = "Response"
    }
}
```

### SwiftUI View Structure

```swift
struct IMDBFilmDetailView: View {
    let film: IMDBFilm
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Poster section
                // Title and basic info section
                // Ratings section
                // Metadata section
                // Plot section
                // Cast section
            }
        }
        .navigationTitle(film.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

## Test Data

### Film 1: Mission: Impossible - The Final Reckoning (2025)

```json
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
  "Response": "True"
}
```

### Film 2: The Dark Knight (2008)

```json
{
  "Title": "The Dark Knight",
  "Year": "2008",
  "Rated": "PG-13",
  "Released": "18 Jul 2008",
  "Runtime": "152 min",
  "Genre": "Action, Crime, Drama",
  "Director": "Christopher Nolan",
  "Writer": "Jonathan Nolan, Christopher Nolan, Bob Kane",
  "Actors": "Christian Bale, Heath Ledger, Aaron Eckhart",
  "Plot": "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.",
  "Language": "English, Mandarin",
  "Country": "United States, United Kingdom",
  "Awards": "Won 2 Oscars. 159 wins & 163 nominations total",
  "Poster": "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg",
  "Ratings": [
    { "Source": "Internet Movie Database", "Value": "9.0/10" },
    { "Source": "Rotten Tomatoes", "Value": "94%" },
    { "Source": "Metacritic", "Value": "84/100" }
  ],
  "Metascore": "84",
  "imdbRating": "9.0",
  "imdbVotes": "2,654,264",
  "imdbID": "tt0468569",
  "Type": "movie",
  "Response": "True"
}
```

### Film 3: Inception (2010)

```json
{
  "Title": "Inception",
  "Year": "2010",
  "Rated": "PG-13",
  "Released": "16 Jul 2010",
  "Runtime": "148 min",
  "Genre": "Action, Sci-Fi, Thriller",
  "Director": "Christopher Nolan",
  "Writer": "Christopher Nolan",
  "Actors": "Leonardo DiCaprio, Marion Cotillard, Elliot Page",
  "Plot": "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O., but his tragic past may doom the project and his team to disaster.",
  "Language": "English, Japanese, French",
  "Country": "United States, United Kingdom",
  "Awards": "Won 4 Oscars. 157 wins & 220 nominations total",
  "Poster": "https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_SX300.jpg",
  "Ratings": [
    { "Source": "Internet Movie Database", "Value": "8.8/10" },
    { "Source": "Rotten Tomatoes", "Value": "87%" },
    { "Source": "Metacritic", "Value": "74/100" }
  ],
  "Metascore": "74",
  "imdbRating": "8.8",
  "imdbVotes": "2,364,425",
  "imdbID": "tt1375666",
  "Type": "movie",
  "Response": "True"
}
```

## Unit Testing Requirements

### Test Categories

#### 1. Data Model Tests (`IMDBFilmTests.swift`)

```swift
class IMDBFilmTests: XCTestCase {
    
    func testIMDBFilmDecoding() {
        // Test JSON decoding from OMDb API response
        // Verify all fields are properly mapped
        // Test missing/optional fields handling
    }
    
    func testIMDBFilmIdentifiable() {
        // Test that id property returns imdbID
        // Test uniqueness across different films
    }
    
    func testRatingDecoding() {
        // Test nested Rating struct decoding
        // Test multiple rating sources
        // Test missing ratings array
    }
    
    func testInvalidDataHandling() {
        // Test malformed JSON responses
        // Test missing required fields
        // Test unexpected data types
    }
}
```

#### 2. View Model Tests (`IMDBFilmDetailViewModelTests.swift`)

```swift
class IMDBFilmDetailViewModelTests: XCTestCase {
    
    func testFormattedRatingDisplay() {
        // Test IMDB rating formatting (e.g., "8.8/10")
        // Test Rotten Tomatoes percentage display
        // Test missing ratings handling
    }
    
    func testGenreChipGeneration() {
        // Test splitting comma-separated genres
        // Test genre list formatting
        // Test empty genre handling
    }
    
    func testRuntimeFormatting() {
        // Test "152 min" display formatting
        // Test missing runtime handling
    }
    
    func testActorListFormatting() {
        // Test comma-separated actor display
        // Test long actor lists truncation
    }
}
```

#### 3. View Tests (`IMDBFilmDetailViewTests.swift`)

```swift
class IMDBFilmDetailViewTests: XCTestCase {
    
    func testViewRendering() {
        // Test view renders without crashing
        // Test all required elements are present
        // Test proper layout with test data
    }
    
    func testAsyncImageHandling() {
        // Test poster loading states
        // Test fallback placeholder display
        // Test invalid URL handling
    }
    
    func testAccessibility() {
        // Test VoiceOver labels
        // Test semantic content types
        // Test dynamic type scaling
    }
    
    func testNavigationIntegration() {
        // Test navigation title display
        // Test back button functionality
    }
}
```

#### 4. Integration Tests (`IMDBFilmIntegrationTests.swift`)

```swift
class IMDBFilmIntegrationTests: XCTestCase {
    
    func testEndToEndFilmDisplay() {
        // Test complete flow from API data to view
        // Test with all three test films
        // Test error states and recovery
    }
}
```

### Test Data Constants

```swift
struct TestData {
    static let missionImpossible = IMDBFilm(/* test data 1 */)
    static let darkKnight = IMDBFilm(/* test data 2 */)
    static let inception = IMDBFilm(/* test data 3 */)
    
    static let allTestFilms = [missionImpossible, darkKnight, inception]
    
    static let invalidJSON = """
    {
        "invalid": "json structure"
    }
    """
    
    static let incompleteFilm = """
    {
        "Title": "Test Film",
        "imdbID": "tt1234567"
        // Missing required fields
    }
    """
}
```

## Acceptance Criteria

✅ **Display Requirements**

- [ ] Poster image loads and displays correctly with proper aspect ratio
- [ ] All film metadata is clearly visible and properly formatted
- [ ] Layout adapts to different screen sizes (iPhone/iPad)
- [ ] Loading states are handled gracefully

✅ **Functionality**

- [ ] View accepts IMDBFilm model and displays all relevant data
- [ ] Ratings from multiple sources display correctly
- [ ] Genre tags are properly separated and styled
- [ ] Scrollable content for long descriptions

✅ **Quality Assurance**

- [ ] All unit tests pass with >90% coverage
- [ ] View handles missing/null data gracefully
- [ ] Accessibility features work correctly
- [ ] Performance is acceptable with large images

✅ **Integration**

- [ ] View integrates smoothly with navigation stack
- [ ] Can be instantiated with test data
- [ ] Error states are properly communicated to user

## Dependencies

- SwiftUI for view implementation
- Foundation for data models and JSON decoding
- AsyncImage for poster loading (iOS 15+)
- XCTest framework for unit testing

## Future Enhancements

- Add sharing functionality for film details
- Implement image caching for better performance
- Add animation transitions between sections
- Support for trailer video previews
- Deep linking to full IMDB page
