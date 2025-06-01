import XCTest
@testable import filmz2

/// Unit tests for IMDBFilmDetailViewModel
/// Tests business logic, data formatting, and edge cases
@MainActor
final class IMDBFilmDetailViewModelTests: XCTestCase {
    
    var viewModel: IMDBFilmDetailViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = IMDBFilmDetailViewModel(film: .darkKnight)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given/When
        let testFilm = IMDBFilm.inception
        let vm = IMDBFilmDetailViewModel(film: testFilm)
        
        // Then
        XCTAssertEqual(vm.film.title, "Inception")
        XCTAssertFalse(vm.isImageLoading)
        XCTAssertNil(vm.imageLoadError)
    }
    
    // MARK: - Formatted Display Tests
    
    func testTitleWithYear() {
        // Given/When
        let titleWithYear = viewModel.titleWithYear
        
        // Then
        XCTAssertEqual(titleWithYear, "The Dark Knight (2008)")
    }
    
    func testGenreChips() {
        // Given/When
        let genres = viewModel.genreChips
        
        // Then
        XCTAssertEqual(genres, ["Action", "Crime", "Drama"])
    }
    
    func testGenreChipsWithEmptyGenres() {
        // Given
        let filmWithEmptyGenre = createFilmWithGenre("")
        let vm = IMDBFilmDetailViewModel(film: filmWithEmptyGenre)
        
        // When
        let genres = vm.genreChips
        
        // Then
        XCTAssertEqual(genres, [])
    }
    
    func testFormattedActors() {
        // Given/When
        let actors = viewModel.formattedActors
        
        // Then
        XCTAssertEqual(actors, "Christian Bale, Heath Ledger, Aaron Eckhart")
    }
    
    func testFormattedWriters() {
        // Given/When
        let writers = viewModel.formattedWriters
        
        // Then
        XCTAssertEqual(writers, "Jonathan Nolan, Christopher Nolan, Bob Kane")
    }
    
    func testFormattedWritersWithNA() {
        // Given
        let filmWithNoWriters = createFilmWithWriter(nil)
        let vm = IMDBFilmDetailViewModel(film: filmWithNoWriters)
        
        // When
        let writers = vm.formattedWriters
        
        // Then
        XCTAssertNil(writers)
    }
    
    func testDirectorInfo() {
        // Given/When
        let directorInfo = viewModel.directorInfo
        
        // Then
        XCTAssertEqual(directorInfo, "Directed by Christopher Nolan")
    }
    
    func testDirectorInfoWithNA() {
        // Given
        let filmWithNoDirector = createFilmWithDirector(nil)
        let vm = IMDBFilmDetailViewModel(film: filmWithNoDirector)
        
        // When
        let directorInfo = vm.directorInfo
        
        // Then
        XCTAssertNil(directorInfo)
    }
    
    func testReleaseInfo() {
        // Given/When
        let releaseInfo = viewModel.releaseInfo
        
        // Then
        XCTAssertEqual(releaseInfo, "Released 18 Jul 2008")
    }
    
    func testReleaseInfoWithNA() {
        // Given
        let filmWithNoRelease = createFilmWithReleased(nil)
        let vm = IMDBFilmDetailViewModel(film: filmWithNoRelease)
        
        // When
        let releaseInfo = vm.releaseInfo
        
        // Then
        XCTAssertNil(releaseInfo)
    }
    
    func testOriginInfo() {
        // Given/When
        let originInfo = viewModel.originInfo
        
        // Then
        XCTAssertEqual(originInfo, "English, Mandarin • United States, United Kingdom")
    }
    
    func testOriginInfoWithNA() {
        // Given
        let filmWithNoOrigin = createFilmWithLanguageAndCountry(nil, nil)
        let vm = IMDBFilmDetailViewModel(film: filmWithNoOrigin)
        
        // When
        let originInfo = vm.originInfo
        
        // Then
        XCTAssertNil(originInfo)
    }
    
    func testAwardsInfo() {
        // Given/When
        let awardsInfo = viewModel.awardsInfo
        
        // Then
        XCTAssertEqual(awardsInfo, "Won 2 Oscars. 159 wins & 163 nominations total")
    }
    
    func testAwardsInfoWithNA() {
        // Given
        let filmWithNoAwards = createFilmWithAwards(nil)
        let vm = IMDBFilmDetailViewModel(film: filmWithNoAwards)
        
        // When
        let awardsInfo = vm.awardsInfo
        
        // Then
        XCTAssertNil(awardsInfo)
    }
    
    func testRatingBadge() {
        // Given/When
        let ratingBadge = viewModel.ratingBadge
        
        // Then
        XCTAssertEqual(ratingBadge, "PG-13")
    }
    
    func testRatingBadgeWithNA() {
        // Given
        let filmWithNoRating = createFilmWithRated(nil)
        let vm = IMDBFilmDetailViewModel(film: filmWithNoRating)
        
        // When
        let ratingBadge = vm.ratingBadge
        
        // Then
        XCTAssertNil(ratingBadge)
    }
    
    // MARK: - Rating Display Tests
    
    func testAvailableRatings() {
        // Given/When
        let ratings = viewModel.availableRatings
        
        // Then
        XCTAssertEqual(ratings.count, 3)
        
        let imdbRating = ratings.first { $0.source == "IMDB" }
        XCTAssertNotNil(imdbRating)
        XCTAssertEqual(imdbRating?.value, "9.0/10")
        XCTAssertEqual(imdbRating?.icon, "star.fill")
        
        let rtRating = ratings.first { $0.source == "Rotten Tomatoes" }
        XCTAssertNotNil(rtRating)
        XCTAssertEqual(rtRating?.value, "94%")
        XCTAssertEqual(rtRating?.icon, "tomato.fill")
        
        let metacriticRating = ratings.first { $0.source == "Metacritic" }
        XCTAssertNotNil(metacriticRating)
        XCTAssertEqual(metacriticRating?.value, "84/100")
        XCTAssertEqual(metacriticRating?.icon, "m.square.fill")
    }
    
    func testAvailableRatingsWithMissingData() {
        // Given
        let vm = IMDBFilmDetailViewModel(film: .missionImpossible)
        
        // When
        let ratings = vm.availableRatings
        
        // Then
        XCTAssertEqual(ratings.count, 1) // Only Rotten Tomatoes
        XCTAssertEqual(ratings[0].source, "Rotten Tomatoes")
        XCTAssertEqual(ratings[0].value, "79%")
    }
    
    // MARK: - State Management Tests
    
    func testUpdateFilm() {
        // Given
        let newFilm = IMDBFilm.inception
        
        // When
        viewModel.updateFilm(newFilm)
        
        // Then
        XCTAssertEqual(viewModel.film.title, "Inception")
        XCTAssertEqual(viewModel.film.imdbID, "tt1375666")
    }
    
    func testSetImageLoading() {
        // Given/When
        viewModel.setImageLoading(true)
        
        // Then
        XCTAssertTrue(viewModel.isImageLoading)
        
        // When
        viewModel.setImageLoading(false)
        
        // Then
        XCTAssertFalse(viewModel.isImageLoading)
    }
    
    func testSetImageError() {
        // Given
        let testError = URLError(.badURL)
        
        // When
        viewModel.setImageError(testError)
        
        // Then
        XCTAssertNotNil(viewModel.imageLoadError)
        
        // When
        viewModel.setImageError(nil)
        
        // Then
        XCTAssertNil(viewModel.imageLoadError)
    }
    
    // MARK: - Utility Method Tests
    
    func testFormattedVotes() {
        // Given/When
        let votes = viewModel.formattedVotes()
        
        // Then
        XCTAssertEqual(votes, "2,654,264 votes")
    }
    
    func testFormattedVotesWithNA() {
        // Given
        let vm = IMDBFilmDetailViewModel(film: .missionImpossible)
        
        // When
        let votes = vm.formattedVotes()
        
        // Then
        XCTAssertNil(votes)
    }
    
    func testShouldTruncatePlot() {
        // Given
        let shortPlotFilm = createFilmWithPlot("Short plot")
        let longPlotFilm = createFilmWithPlot(String(repeating: "A", count: 400))
        
        let shortVM = IMDBFilmDetailViewModel(film: shortPlotFilm)
        let longVM = IMDBFilmDetailViewModel(film: longPlotFilm)
        
        // When/Then
        XCTAssertFalse(shortVM.shouldTruncatePlot())
        XCTAssertTrue(longVM.shouldTruncatePlot())
    }
    
    func testTruncatedPlot() {
        // Given
        let longPlot = String(repeating: "A", count: 400)
        let longPlotFilm = createFilmWithPlot(longPlot)
        let vm = IMDBFilmDetailViewModel(film: longPlotFilm)
        
        // When
        let truncated = vm.truncatedPlot()
        
        // Then
        XCTAssertTrue(truncated.count <= 303) // 300 + "..."
        XCTAssertTrue(truncated.hasSuffix("..."))
    }
    
    func testTruncatedPlotWithShortText() {
        // Given
        let shortPlot = "Short plot"
        let shortPlotFilm = createFilmWithPlot(shortPlot)
        let vm = IMDBFilmDetailViewModel(film: shortPlotFilm)
        
        // When
        let truncated = vm.truncatedPlot()
        
        // Then
        XCTAssertEqual(truncated, shortPlot)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func createFilmWithWriter(_ writer: String?) -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2023",
            rated: "PG",
            released: "01 Jan 2023",
            runtime: "120 min",
            genre: "Action",
            director: "Test Director",
            writer: writer,
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
    
    private func createFilmWithDirector(_ director: String?) -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2023",
            rated: "PG",
            released: "01 Jan 2023",
            runtime: "120 min",
            genre: "Action",
            director: director,
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
    
    private func createFilmWithReleased(_ released: String?) -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2023",
            rated: "PG",
            released: released,
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
            metascore: nil,
            imdbRating: nil,
            imdbVotes: nil,
            type: "movie",
            response: "True"
        )
    }
    
    private func createFilmWithLanguageAndCountry(_ language: String?, _ country: String?) -> IMDBFilm {
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
            language: language,
            country: country,
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
    
    private func createFilmWithAwards(_ awards: String?) -> IMDBFilm {
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
            awards: awards,
            poster: "https://example.com/poster.jpg",
            ratings: [],
            metascore: nil,
            imdbRating: nil,
            imdbVotes: nil,
            type: "movie",
            response: "True"
        )
    }
    
    private func createFilmWithRated(_ rated: String?) -> IMDBFilm {
        IMDBFilm(
            title: "Test",
            imdbID: "tt1234567",
            year: "2023",
            rated: rated,
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
            metascore: nil,
            imdbRating: nil,
            imdbVotes: nil,
            type: "movie",
            response: "True"
        )
    }
    
    private func createFilmWithPlot(_ plot: String) -> IMDBFilm {
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
            plot: plot,
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
}