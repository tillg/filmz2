import SwiftUI

/// Detail view for displaying comprehensive IMDB film information
/// Follows the layout specification with poster at top and metadata below
struct IMDBFilmDetailView: View {
    @StateObject private var viewModel: IMDBFilmDetailViewModel
    
    // MARK: - Initialization
    
    init(film: IMDBFilm) {
        self._viewModel = StateObject(wrappedValue: IMDBFilmDetailViewModel(film: film))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Film Poster Section
                FilmPosterSection(
                    posterURL: viewModel.film.posterURL,
                    title: viewModel.film.title
                )
                
                // Title and Basic Info Section
                titleSection
                
                // Add to Collection Button
                AddToCollectionButtonLarge(imdbFilm: viewModel.film)
                    .padding(.horizontal)
                
                // Show loading indicator if fetching details
                if viewModel.isLoadingDetails {
                    ProgressView("Loading film details...")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if let error = viewModel.loadError {
                    // Show error if loading failed
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Failed to load film details")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // Show full details only when loaded
                    
                    // Ratings Section
                    if viewModel.film.hasRatings {
                        ratingsSection
                    }
                    
                    // Metadata Section
                    FilmMetadataSection(
                        genres: viewModel.genreChips,
                        director: viewModel.film.director,
                        actors: viewModel.film.actors,
                        writers: viewModel.film.writer,
                        released: viewModel.film.released,
                        runtime: viewModel.film.runtime,
                        language: viewModel.film.language,
                        country: viewModel.film.country,
                        awards: viewModel.film.awards
                    )
                    
                    // Plot Section
                    if let plot = viewModel.film.plot {
                        ExpandablePlot(plot: plot)
                    }
                    
                    // Cast and Crew Section
                    FilmCastAndCrewSection(
                        actors: viewModel.film.actors,
                        writers: viewModel.film.writer
                    )
                    
                    // Additional Information
                    additionalInfoSection
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .navigationTitle(viewModel.film.title)
    }
    
    // MARK: - View Components
    
    private var titleSection: some View {
        HStack {
            Text(viewModel.film.yearAndRuntime)
                .font(.title2)
                .foregroundColor(.secondary)
            
            if let rating = viewModel.ratingBadge {
                Spacer()
                Text(rating)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }
    
    private var ratingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ratings")
                .font(.headline)
                .fontWeight(.semibold)
            
            RatingsRow(film: viewModel.film)
            
            if let votes = viewModel.formattedVotes() {
                Text(votes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    
    @ViewBuilder
    private var additionalInfoSection: some View {
        if let type = viewModel.film.type {
            VStack(alignment: .leading, spacing: 12) {
                Text("Additional Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
                    FilmInfoRow(title: "Type", content: type.capitalized)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Dark Knight") {
    NavigationView {
        IMDBFilmDetailView(film: .darkKnight)
    }
}

#Preview("Mission Impossible") {
    NavigationView {
        IMDBFilmDetailView(film: .missionImpossible)
    }
}

#Preview("Inception") {
    NavigationView {
        IMDBFilmDetailView(film: .inception)
    }
}

#Preview("Minimal Data") {
    NavigationView {
        IMDBFilmDetailView(film: .minimalFilm)
    }
}

#Preview("Navigation Stack") {
    NavigationStack {
        List(IMDBFilm.sampleFilms, id: \.id) { film in
            NavigationLink(destination: IMDBFilmDetailView(film: film)) {
                VStack(alignment: .leading) {
                    Text(film.title)
                        .font(.headline)
                    Text(film.yearAndRuntime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Sample Films")
    }
}
