//
//  MyFilmCell.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI
import SwiftData

/// Cell component for displaying a film from the user's collection
/// Shows rich information including personal rating, watch status, and genres
struct MyFilmCell: View {
    let film: MyFilm
    let filmDetails: IMDBFilm?
    @State private var isLoadingDetails = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster
            posterView
            
            // Film Info
            VStack(alignment: .leading, spacing: 4) {
                // Title and Year
                titleSection
                
                // Personal Status
                statusSection
                
                // IMDB Rating if available
                if let details = filmDetails, let rating = details.imdbRating {
                    IMDBRatingView(rating: rating)
                        .font(.caption)
                }
                
                // Genre Pills
                if let details = filmDetails {
                    genreSection(details: details)
                }
            }
            
            Spacer()
            
            // Collection Indicator & Chevron
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.green)
                
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
    
    // MARK: - Subviews
    
    private var posterView: some View {
        Group {
            if let details = filmDetails {
                AsyncImage(url: details.posterURL) { phase in
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
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.5)
                    )
            }
        }
        .frame(width: 60, height: 90)
    }
    
    private var titleSection: some View {
        Group {
            if let details = filmDetails {
                Text(details.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(details.displayYear ?? "Unknown Year")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statusSection: some View {
        HStack(spacing: 8) {
            // Watch Status
            if film.watched {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    if let date = film.dateWatched {
                        Text(date, style: .date)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Label("Not watched", systemImage: "eye.slash")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            
            // Rating
            MyRatingView(rating: film.myRating)
                .font(.caption)
        }
    }
    
    private func genreSection(details: IMDBFilm) -> some View {
        Group {
            let genres = details.genreList
            if !genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(Array(genres.prefix(3)), id: \.self) { genre in
                            GenrePill(genre, style: .compact)
                        }
                        if genres.count > 3 {
                            Text("...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                        }
                    }
                }
                .frame(height: 20)
            }
        }
    }
}

// MARK: - Previews

#Preview("My Film Cell - Various States") {
    VStack(spacing: 0) {
        // Watched with rating
        MyFilmCell(
            film: {
                let film = MyFilm(imdbID: "tt0111161")
                film.watched = true
                film.myRating = 9
                film.dateWatched = Date().addingTimeInterval(-86400 * 30) // 30 days ago
                return film
            }(),
            filmDetails: IMDBFilm(
                title: "The Shawshank Redemption",
                imdbID: "tt0111161",
                year: "1994",
                genre: "Drama",
                poster: "https://m.media-amazon.com/images/M/MV5BMDFkYTc0MGEtZmNhMC00ZDIzLWFmNTEtODM1ZmRlYWMwMWFmXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg"
            )
        )
        
        Divider().padding(.leading, 88)
        
        // Not watched
        MyFilmCell(
            film: MyFilm(imdbID: "tt0468569"),
            filmDetails: IMDBFilm(
                title: "The Dark Knight",
                imdbID: "tt0468569",
                year: "2008",
                genre: "Action, Crime, Drama",
                poster: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg"
            )
        )
        
        Divider().padding(.leading, 88)
        
        // Watched without rating
        MyFilmCell(
            film: {
                let film = MyFilm(imdbID: "tt1375666")
                film.watched = true
                film.dateWatched = Date()
                return film
            }(),
            filmDetails: IMDBFilm(
                title: "Inception",
                imdbID: "tt1375666",
                year: "2010",
                genre: "Action, Sci-Fi, Thriller",
                poster: "https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_SX300.jpg"
            )
        )
        
        Divider().padding(.leading, 88)
        
        // Loading state
        MyFilmCell(
            film: MyFilm(imdbID: "tt0133093"),
            filmDetails: nil
        )
    }
    .modelContainer(for: MyFilm.self, inMemory: true)
}

#Preview("My Film Cell - Long Title") {
    MyFilmCell(
        film: MyFilm(imdbID: "tt0062622"),
        filmDetails: IMDBFilm(
            title: "2001: A Space Odyssey - A Very Long Title That Should Be Truncated",
            imdbID: "tt0062622",
            year: "1968",
            genre: "Sci-Fi",
            poster: "N/A"
        )
    )
    .padding()
    .modelContainer(for: MyFilm.self, inMemory: true)
}