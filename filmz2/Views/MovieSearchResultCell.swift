import SwiftUI

struct MovieSearchResultCell: View {
    let result: OMDBSearchItem
    
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

#Preview {
    VStack(spacing: 0) {
        MovieSearchResultCell(
            result: OMDBSearchItem(
                title: "The Dark Knight",
                year: "2008",
                imdbID: "tt0468569",
                type: "movie",
                poster: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg"
            )
        )
        
        Divider().padding(.leading, 88)
        
        MovieSearchResultCell(
            result: OMDBSearchItem(
                title: "Inception with a Very Long Title That Should Be Truncated",
                year: "2010",
                imdbID: "tt1375666",
                type: "movie",
                poster: "N/A"
            )
        )
        
        Divider().padding(.leading, 88)
        
        MovieSearchResultCell(
            result: OMDBSearchItem(
                title: "See",
                year: "2019–2022",
                imdbID: "tt7949218",
                type: "series",
                poster: "https://m.media-amazon.com/images/M/MV5BYmJkYjAyY2ItYmNhZi00OTVmLWIyODctNTNhNWRiZTlmZWUzXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_SX300.jpg"
            )
        )
    }
}