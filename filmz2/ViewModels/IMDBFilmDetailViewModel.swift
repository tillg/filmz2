import Foundation
import SwiftUI

/// View model for IMDB film detail view
/// Handles business logic and data formatting for film presentation
@MainActor
class IMDBFilmDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var film: IMDBFilm
    @Published private(set) var isImageLoading = false
    @Published private(set) var imageLoadError: Error?
    @Published private(set) var isLoadingDetails = false
    @Published private(set) var loadError: String?
    
    // MARK: - Initialization
    
    init(film: IMDBFilm) {
        self.film = film
        // If we only have basic info (no plot, director, etc.), fetch full details
        if needsFullDetails {
            Task {
                await fetchFullDetails()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var needsFullDetails: Bool {
        // Check if we have full details by looking for fields that only come from detail API
        return film.plot == nil && film.director == nil && film.actors == nil
    }
    
    // MARK: - Computed Properties
    
    /// Formatted title with year
    var titleWithYear: String {
        if let year = film.year {
            return "\(film.title) (\(year))"
        } else {
            return film.title
        }
    }
    
    /// Genre chips for display
    var genreChips: [String] {
        film.genreList
    }
    
    /// Actor list formatted for display, nil if no actors
    var formattedActors: String? {
        let actors = film.actorList
        return actors.isEmpty ? nil : actors.joined(separator: ", ")
    }
    
    /// Writer credits formatted for display, nil if no writers
    var formattedWriters: String? {
        film.writer
    }
    
    /// Director information, nil if no director
    var directorInfo: String? {
        guard let director = film.director else { return nil }
        return "Directed by \(director)"
    }
    
    /// Release information formatted nicely, nil if no release date
    var releaseInfo: String? {
        guard let released = film.released else { return nil }
        return "Released \(released)"
    }
    
    /// Language and country information, nil if no origin data
    var originInfo: String? {
        let parts = [film.language, film.country].compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " • ")
    }
    
    /// Awards information if available
    var awardsInfo: String? {
        film.awards
    }
    
    /// Rating badge text (PG, R, etc.)
    var ratingBadge: String? {
        film.ratingClassification
    }
    
    /// All available ratings for display
    var availableRatings: [RatingDisplayInfo] {
        var ratings: [RatingDisplayInfo] = []
        
        // IMDB Rating
        if let imdbRating = film.formattedIMDBRating {
            ratings.append(RatingDisplayInfo(
                source: "IMDB",
                value: imdbRating,
                icon: "star.fill",
                color: .yellow
            ))
        }
        
        // Rotten Tomatoes
        if let rtRating = film.rottenTomatoesRating {
            ratings.append(RatingDisplayInfo(
                source: "Rotten Tomatoes",
                value: rtRating,
                icon: "tomato.fill",
                color: .red
            ))
        }
        
        // Metacritic
        if let metacritic = film.metacriticRating {
            ratings.append(RatingDisplayInfo(
                source: "Metacritic",
                value: metacritic,
                icon: "m.square.fill",
                color: .blue
            ))
        }
        
        return ratings
    }
    
    // MARK: - Methods
    
    /// Updates the film data (for future use)
    func updateFilm(_ newFilm: IMDBFilm) {
        self.film = newFilm
    }
    
    /// Handles image loading state updates
    func setImageLoading(_ loading: Bool) {
        isImageLoading = loading
    }
    
    /// Handles image loading errors
    func setImageError(_ error: Error?) {
        imageLoadError = error
    }
    
    /// Returns formatted votes count
    func formattedVotes() -> String? {
        guard let votes = film.imdbVotes, votes != "N/A" else { return nil }
        return "\(votes) votes"
    }
    
    /// Determines if the plot should be truncated
    func shouldTruncatePlot(maxLength: Int = 300) -> Bool {
        guard let plot = film.plot else { return false }
        return plot.count > maxLength
    }
    
    /// Returns truncated plot for preview
    func truncatedPlot(maxLength: Int = 300) -> String {
        guard let plot = film.plot else { return "" }
        guard plot.count > maxLength else { return plot }
        let truncated = String(plot.prefix(maxLength))
        return truncated + "..."
    }
    
    // MARK: - Private Methods
    
    /// Fetches full film details from API
    private func fetchFullDetails() async {
        isLoadingDetails = true
        loadError = nil
        
        do {
            let fullDetails = try await OMDBSearchService.shared.getFilm(byID: film.imdbID)
            self.film = fullDetails
            isLoadingDetails = false
        } catch {
            loadError = error.localizedDescription
            isLoadingDetails = false
        }
    }
}

// MARK: - Supporting Types

struct RatingDisplayInfo {
    let source: String
    let value: String
    let icon: String
    let color: Color
}

// MARK: - Preview Support

#if DEBUG
extension IMDBFilmDetailViewModel {
    static let preview = IMDBFilmDetailViewModel(film: .darkKnight)
    static let previewMissionImpossible = IMDBFilmDetailViewModel(film: .missionImpossible)
    static let previewInception = IMDBFilmDetailViewModel(film: .inception)
}
#endif