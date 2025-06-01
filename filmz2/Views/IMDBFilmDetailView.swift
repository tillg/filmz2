import SwiftUI

/// Detail view for displaying comprehensive IMDB film information
/// Follows the layout specification with poster at top and metadata below
struct IMDBFilmDetailView: View {
    @StateObject private var viewModel: IMDBFilmDetailViewModel
    @State private var showFullPlot = false
    
    // MARK: - Initialization
    
    init(film: IMDBFilm) {
        self._viewModel = StateObject(wrappedValue: IMDBFilmDetailViewModel(film: film))
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Film Poster Section
                posterSection
                
                // Title and Basic Info Section
                titleSection
                
                // Ratings Section
                if viewModel.film.hasRatings {
                    ratingsSection
                }
                
                // Metadata Section
                metadataSection
                
                // Plot Section
                plotSection
                
                // Cast and Crew Section
                castAndCrewSection
                
                // Additional Information
                additionalInfoSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .navigationTitle(viewModel.film.title)
    }
    
    // MARK: - View Components
    
    private var posterSection: some View {
        HStack {
            Spacer()
            AsyncImage(url: viewModel.film.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2/3, contentMode: .fit)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Poster")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            .frame(maxHeight: 400)
            Spacer()
        }
    }
    
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
            
            RatingPills(viewModel.availableRatings, layout: .horizontal)
            
            if let votes = viewModel.formattedVotes() {
                Text(votes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Genres
            if !viewModel.genreChips.isEmpty {
                GenrePills(viewModel.genreChips)
            }
            
            // Director
            if let directorInfo = viewModel.directorInfo {
                InfoRow(title: "Director", content: directorInfo)
            }
            
            // Release Info
            if let releaseInfo = viewModel.releaseInfo {
                InfoRow(title: "Released", content: releaseInfo)
            }
            
            // Origin
            if let originInfo = viewModel.originInfo {
                InfoRow(title: "Origin", content: originInfo)
            }
            
            // Awards
            if let awards = viewModel.awardsInfo {
                InfoRow(title: "Awards", content: awards)
            }
        }
    }
    
    @ViewBuilder
    private var plotSection: some View {
        if let plot = viewModel.film.plot {
            VStack(alignment: .leading, spacing: 12) {
                Text("Plot")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(showFullPlot ? plot : viewModel.truncatedPlot())
                        .font(.body)
                        .lineSpacing(4)
                    
                    if viewModel.shouldTruncatePlot() {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showFullPlot.toggle()
                            }
                        }) {
                            Text(showFullPlot ? "Show Less" : "Read More")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var castAndCrewSection: some View {
        let hasActors = viewModel.formattedActors != nil
        let hasWriters = viewModel.formattedWriters != nil
        
        if hasActors || hasWriters {
            VStack(alignment: .leading, spacing: 16) {
                Text("Cast & Crew")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let actors = viewModel.formattedActors {
                    InfoRow(title: "Starring", content: actors)
                }
                
                if let writers = viewModel.formattedWriters {
                    InfoRow(title: "Writers", content: writers)
                }
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
                    InfoRow(title: "Type", content: type.capitalized)
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct InfoRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(content)
                .font(.body)
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
