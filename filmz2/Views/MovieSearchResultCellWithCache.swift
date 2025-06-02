import SwiftUI
import SwiftData

/// A wrapper view that fetches cached data for MovieSearchResultCell
struct MovieSearchResultCellWithCache: View {
    let result: OMDBSearchItem
    @State private var cachedFilm: CachedIMDBFilm?
    
    var body: some View {
        MovieSearchResultCellContent(result: result, cachedFilm: cachedFilm)
            .onAppear {
                fetchCachedFilm()
            }
            .onChange(of: result.imdbID) { _, _ in
                fetchCachedFilm()
            }
    }
    
    private func fetchCachedFilm() {
        cachedFilm = CacheManager.shared.fetchFilm(imdbID: result.imdbID)
    }
}

/// The actual cell content view
struct MovieSearchResultCellContent: View {
    let result: OMDBSearchItem
    let cachedFilm: CachedIMDBFilm?
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster
            AsyncImage(url: URL(string: result.poster ?? "")) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .tint(.gray)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 90)
                        .clipped()
                        .cornerRadius(8)
                case .failure(_):
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 90)
            
            // Film Info
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(result.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                // Year
                Text(result.year)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Type (as a simple label, similar to genre pills)
                HStack {
                    Text(result.type.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // IMDB Rating if available from cache
                if let rating = cachedFilm?.imdbRating {
                    IMDBRatingView(rating: rating)
                        .font(.caption)
                }
            }
            
            Spacer()
            
            // Add Button & Chevron (stacked vertically like MyFilmCell)
            VStack(spacing: 8) {
                AddToCollectionButton(searchItem: result)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview("Search Results") {
    VStack(spacing: 0) {
        MovieSearchResultCellWithCache(
            result: OMDBSearchItem(
                title: "The Dark Knight",
                year: "2008",
                imdbID: "tt0468569",
                type: "movie",
                poster: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg"
            )
        )
        
        Divider().padding(.leading, 88)
        
        MovieSearchResultCellWithCache(
            result: OMDBSearchItem(
                title: "Inception with a Very Long Title That Should Be Truncated",
                year: "2010",
                imdbID: "tt1375666",
                type: "movie",
                poster: "N/A"
            )
        )
        
        Divider().padding(.leading, 88)
        
        MovieSearchResultCellWithCache(
            result: OMDBSearchItem(
                title: "See",
                year: "2019–2022",
                imdbID: "tt7949218",
                type: "series",
                poster: "https://m.media-amazon.com/images/M/MV5BYmJkYjAyY2ItYmNhZi00OTVmLWIyODctNTNhNWRiZTlmZWUzXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_SX300.jpg"
            )
        )
    }
    .modelContainer(for: [CachedIMDBFilm.self], inMemory: true)
}