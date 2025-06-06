//
//  MyFilmCell.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//  Updated to follow Apple Human Interface Guidelines
//

import SwiftUI
import SwiftData

/// Cell component for displaying a film from the user's collection
/// Shows rich information including personal rating, watch status, and genres
/// Updated to follow Apple Human Interface Guidelines
struct MyFilmCell: View {
    let film: MyFilm
    let filmDetails: IMDBFilm?
    @State private var isLoadingDetails = false
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.small.rawValue) {
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
                        .font(DesignTokens.Typography.caption)
                }
                
                // Genre Pills
                if let details = filmDetails {
                    genreSection(details: details)
                }
            }
            
            Spacer()
            
            // Collection Indicator & Chevron
            VStack(spacing: DesignTokens.Spacing.extraSmall.rawValue) {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(DesignTokens.Colors.success)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.secondary)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.small.rawValue)
        .padding(.vertical, DesignTokens.Spacing.extraSmall.rawValue)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }
    
    // MARK: - Subviews
    
    private var posterView: some View {
        Group {
            if let details = filmDetails {
                AsyncImage(url: details.posterURL) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small.rawValue)
                            .fill(DesignTokens.Colors.tertiaryFill)
                            .overlay(
                                ProgressView()
                                    .tint(DesignTokens.Colors.secondary)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 90)
                            .clipped()
                            .appleCornerRadius(.small)
                    case .failure(_):
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small.rawValue)
                            .fill(DesignTokens.Colors.tertiaryFill)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(DesignTokens.Colors.secondary)
                                    .font(DesignTokens.Typography.title2)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small.rawValue)
                    .fill(DesignTokens.Colors.tertiaryFill)
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
                    .font(DesignTokens.Typography.headline)
                    .lineLimit(1)
                    .foregroundColor(DesignTokens.Colors.primary)
                
                Text(details.displayYear ?? "Unknown Year")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.secondary)
            } else {
                Text("Loading...")
                    .font(DesignTokens.Typography.headline)
                    .foregroundColor(DesignTokens.Colors.secondary)
            }
        }
    }
    
    private var statusSection: some View {
        HStack(spacing: DesignTokens.Spacing.extraSmall.rawValue) {
            // Watch Status
            if film.watched {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.success)
                    
                    if let date = film.dateWatched {
                        Text(date, style: .date)
                            .font(DesignTokens.Typography.caption2)
                            .foregroundColor(DesignTokens.Colors.secondary)
                    }
                }
            } else {
                Label("Not watched", systemImage: "eye.slash")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.warning)
            }
            
            // Rating
            MyRatingView(rating: film.myRating)
                .font(DesignTokens.Typography.caption)
        }
    }
    
    private var accessibilityDescription: String {
        var description = ""
        if let details = filmDetails {
            description = "\(details.title), \(details.displayYear ?? "Unknown year")"
        } else {
            description = "Film loading"
        }
        
        if film.watched {
            description += ", watched"
            if let rating = film.myRating {
                description += ", rated \(rating) out of 10"
            }
        } else {
            description += ", not watched yet"
        }
        
        return description
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