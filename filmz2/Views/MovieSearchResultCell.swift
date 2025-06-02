import SwiftUI

struct MovieSearchResultCell: View {
    let result: OMDBSearchItem
    
    var body: some View {
        HStack(spacing: 12) {
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Text(result.year)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(result.type.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Spacer()
            
            AddToCollectionButton(searchItem: result)
                .padding(.trailing, 8)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack {
        MovieSearchResultCell(
            result: OMDBSearchItem(
                title: "The Dark Knight",
                year: "2008",
                imdbID: "tt0468569",
                type: "movie",
                poster: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg"
            )
        )
        .padding(.horizontal)
        
        Divider()
        
        MovieSearchResultCell(
            result: OMDBSearchItem(
                title: "Inception with a Very Long Title That Should Be Truncated",
                year: "2010",
                imdbID: "tt1375666",
                type: "movie",
                poster: "N/A"
            )
        )
        .padding(.horizontal)
    }
}