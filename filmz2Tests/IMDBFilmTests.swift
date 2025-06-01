import XCTest
@testable import filmz2

/// Unit tests for IMDBFilm data model
/// Tests JSON decoding, computed properties, and edge cases
final class IMDBFilmTests: XCTestCase {
    
    // MARK: - JSON Decoding Tests
    
    func testIMDBFilmDecoding() throws {
        // Given
        let jsonData = sampleDarkKnightJSON.data(using: .utf8)!
        
        // When
        let film = try JSONDecoder().decode(IMDBFilm.self, from: jsonData)
        
        // Then
        XCTAssertEqual(film.title, "The Dark Knight")
        XCTAssertEqual(film.year, "2008")
        XCTAssertEqual(film.imdbID, "tt0468569")
        XCTAssertEqual(film.id, "tt0468569") // Test Identifiable conformance
        XCTAssertEqual(film.ratings?.count, 3)
        XCTAssertEqual(film.ratings?[0].source, "Internet Movie Database")
        XCTAssertEqual(film.ratings?[0].value, "9.0/10")
    }
    
    func testIMDBFilmDecodingWithMissingOptionalFields() throws {
        // Given
        let jsonData = sampleMinimalJSON.data(using: .utf8)!
        
        // When
        let film = try JSONDecoder().decode(IMDBFilm.self, from: jsonData)
        
        // Then
        XCTAssertEqual(film.title, "Test Film")
        XCTAssertEqual(film.imdbID, "tt1234567")
        XCTAssertNil(film.metascore)
        XCTAssertNil(film.imdbRating)
        XCTAssertNil(film.imdbVotes)
    }
    
    func testRatingDecoding() throws {
        // Given
        let jsonData = sampleDarkKnightJSON.data(using: .utf8)!
        
        // When
        let film = try JSONDecoder().decode(IMDBFilm.self, from: jsonData)
        
        // Then
        XCTAssertEqual(film.ratings?.count, 3)
        
        let imdbRating = film.ratings?.first { $0.source == "Internet Movie Database" }
        XCTAssertNotNil(imdbRating)
        XCTAssertEqual(imdbRating?.value, "9.0/10")
        
        let rtRating = film.ratings?.first { $0.source == "Rotten Tomatoes" }
        XCTAssertNotNil(rtRating)
        XCTAssertEqual(rtRating?.value, "94%")
    }
    
    func testInvalidDataHandling() {
        // Given
        let invalidJSON = "{\"invalid\": \"json structure\"}".data(using: .utf8)!
        
        // When/Then
        XCTAssertThrowsError(try JSONDecoder().decode(IMDBFilm.self, from: invalidJSON)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    // MARK: - Computed Properties Tests
    
    func testPosterURL() {
        // Given
        let filmWithValidURL = IMDBFilm.darkKnight
        let filmWithNoPoster = createFilmWithPoster(nil)
        
        // When/Then
        XCTAssertNotNil(filmWithValidURL.posterURL)
        XCTAssertNil(filmWithNoPoster.posterURL)
    }
    
    func testGenreList() {
        // Given
        let film = IMDBFilm.darkKnight
        
        // When
        let genres = film.genreList
        
        // Then
        XCTAssertEqual(genres, ["Action", "Crime", "Drama"])
    }
    
    func testActorList() {
        // Given
        let film = IMDBFilm.darkKnight
        
        // When
        let actors = film.actorList
        
        // Then
        XCTAssertEqual(actors, ["Christian Bale", "Heath Ledger", "Aaron Eckhart"])
    }
    
    func testFormattedIMDBRating() {
        // Given
        let filmWithRating = IMDBFilm.darkKnight
        let filmWithoutRating = IMDBFilm.missionImpossible
        
        // When/Then
        XCTAssertEqual(filmWithRating.formattedIMDBRating, "9.0/10")
        XCTAssertNil(filmWithoutRating.formattedIMDBRating)
    }
    
    func testRottenTomatoesRating() {
        // Given
        let film = IMDBFilm.darkKnight
        
        // When
        let rtRating = film.rottenTomatoesRating
        
        // Then
        XCTAssertEqual(rtRating, "94%")
    }
    
    func testMetacriticRating() {
        // Given
        let filmWithScore = IMDBFilm.darkKnight
        let filmWithoutScore = IMDBFilm.missionImpossible
        
        // When/Then
        XCTAssertEqual(filmWithScore.metacriticRating, "84/100")
        XCTAssertNil(filmWithoutScore.metacriticRating)
    }
    
    func testFormattedRuntime() {
        // Given
        let filmWithRuntime = IMDBFilm.darkKnight
        let filmWithoutRuntime = createFilmWithRuntime(nil)
        
        // When/Then
        XCTAssertEqual(filmWithRuntime.formattedRuntime, "152 min")
        XCTAssertNil(filmWithoutRuntime.formattedRuntime)
    }
    
    func testYearAndRuntime() {
        // Given
        let filmWithRuntime = IMDBFilm.darkKnight
        let filmWithoutRuntime = createFilmWithRuntime(nil)
        
        // When/Then
        XCTAssertEqual(filmWithRuntime.yearAndRuntime, "2008 • 152 min")
        XCTAssertEqual(filmWithoutRuntime.yearAndRuntime, "2008")
    }
    
    func testHasRatings() {
        // Given
        let filmWithRatings = IMDBFilm.darkKnight
        let filmWithoutRatings = IMDBFilm.minimalFilm
        
        // When/Then
        XCTAssertTrue(filmWithRatings.hasRatings)
        XCTAssertFalse(filmWithoutRatings.hasRatings)
    }
    
    // MARK: - Identifiable Tests
    
    func testIMDBFilmIdentifiable() {
        // Given
        let film1 = IMDBFilm.darkKnight
        let film2 = IMDBFilm.inception
        
        // When/Then
        XCTAssertEqual(film1.id, film1.imdbID)
        XCTAssertEqual(film2.id, film2.imdbID)
        XCTAssertNotEqual(film1.id, film2.id)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyGenreHandling() {
        // Given
        let filmWithEmptyGenre = createFilmWithGenre("")
        
        // When
        let genres = filmWithEmptyGenre.genreList
        
        // Then
        XCTAssertEqual(genres, [])
    }
    
    func testNAFieldsHandling() {
        // Given
        let film = IMDBFilm.missionImpossible
        
        // When/Then
        XCTAssertNil(film.formattedIMDBRating)
        XCTAssertNil(film.metacriticRating)
        XCTAssertEqual(film.formattedRuntime, "169 min") // This one has valid runtime
    }
    
    // MARK: - Helper Methods
    
    private func createFilmWithPoster(_ poster: String?) -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2023",
            rated: "PG",
            released: "01 Jan 2023",
            runtime: "120 min",
            genre: "Action",
            director: "Test Director",
            writer: "Test Writer",
            actors: "Test Actor",
            plot: "Test plot",
            language: "English",
            country: "USA",
            awards: "None",
            poster: poster,
            ratings: [],
            metascore: nil,
            imdbRating: nil,
            imdbVotes: nil,
            type: "movie",
            response: "True"
        )
    }
    
    private func createFilmWithRuntime(_ runtime: String?) -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2008",
            rated: "PG",
            released: "01 Jan 2008",
            runtime: runtime,
            genre: "Action",
            director: "Test Director",
            writer: "Test Writer",
            actors: "Test Actor",
            plot: "Test plot",
            language: "English",
            country: "USA",
            awards: "None",
            poster: "https://example.com/poster.jpg",
            ratings: [],
            metascore: nil,
            imdbRating: nil,
            imdbVotes: nil,
            type: "movie",
            response: "True"
        )
    }
    
    private func createFilmWithGenre(_ genre: String) -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2023",
            rated: "PG",
            released: "01 Jan 2023",
            runtime: "120 min",
            genre: genre,
            director: "Test Director",
            writer: "Test Writer",
            actors: "Test Actor",
            plot: "Test plot",
            language: "English",
            country: "USA",
            awards: "None",
            poster: "https://example.com/poster.jpg",
            ratings: [],
            metascore: nil,
            imdbRating: nil,
            imdbVotes: nil,
            type: "movie",
            response: "True"
        )
    }
    
    private func createFilmWithoutRatings() -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2023",
            rated: "PG",
            released: "01 Jan 2023",
            runtime: "120 min",
            genre: "Action",
            director: "Test Director",
            writer: "Test Writer",
            actors: "Test Actor",
            plot: "Test plot",
            language: "English",
            country: "USA",
            awards: "None",
            poster: "https://example.com/poster.jpg",
            ratings: [],
            metascore: "N/A",
            imdbRating: "N/A",
            imdbVotes: "N/A",
            type: "movie",
            response: "True"
        )
    }
    
    // MARK: - Test Data
    
    private let sampleDarkKnightJSON = """
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
    """
    
    private let sampleMinimalJSON = """
    {
      "Title": "Test Film",
      "Year": "2023",
      "Rated": "N/A",
      "Released": "N/A",
      "Runtime": "N/A",
      "Genre": "N/A",
      "Director": "N/A",
      "Writer": "N/A",
      "Actors": "N/A",
      "Plot": "N/A",
      "Language": "N/A",
      "Country": "N/A",
      "Awards": "N/A",
      "Poster": "N/A",
      "Ratings": [],
      "imdbID": "tt1234567",
      "Type": "movie",
      "Response": "True"
    }
    """
}