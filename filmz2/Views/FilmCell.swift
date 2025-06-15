//
//  FilmCell.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI
import SwiftData

/// Wrapper cell component that intelligently decides how to display a film
/// based on whether it's in the user's collection or not.
/// 
/// This is the central component for displaying films throughout the app,
/// ensuring consistent UI whether in search results or collection views.
struct FilmCell: View {
    let searchResult: OMDBSearchItem?
    let cachedDetails: IMDBFilm?
    
    @Environment(\.myFilmsStore) private var myFilmsStore
    @State private var myFilm: MyFilm?
    @State private var fetchedDetails: IMDBFilm?
    
    /// Initialize with search result
    init(searchResult: OMDBSearchItem) {
        self.searchResult = searchResult
        self.cachedDetails = nil
    }
    
    /// Initialize with cached film details
    init(cachedDetails: IMDBFilm) {
        self.searchResult = nil
        self.cachedDetails = cachedDetails
    }
    
    /// Initialize with both (e.g., when we have full details from search)
    init(searchResult: OMDBSearchItem? = nil, cachedDetails: IMDBFilm? = nil) {
        self.searchResult = searchResult
        self.cachedDetails = cachedDetails
    }
    
    var imdbID: String {
        searchResult?.imdbID ?? cachedDetails?.imdbID ?? ""
    }
    
    var body: some View {
        Group {
            if let myFilm = myFilm {
                // Film is in collection - show rich view with personal data
                NavigationLink(destination: MyFilmDetailView(film: myFilm)) {
                    MyFilmCell(film: myFilm, filmDetails: cachedDetails ?? fetchedDetails)
                }
                .buttonStyle(PlainButtonStyle())
            } else if let searchResult = searchResult {
                // Not in collection - show search result view
                NavigationLink(destination: IMDBFilmDetailView(searchItem: searchResult)) {
                    MovieSearchResultCellWithCache(result: searchResult)
                }
                .buttonStyle(PlainButtonStyle())
            } else if let cachedDetails = cachedDetails {
                // We have cached details but it's not in collection
                NavigationLink(destination: IMDBFilmDetailView(film: cachedDetails)) {
                    MovieSearchResultCellWithCache(result: OMDBSearchItem(
                        title: cachedDetails.title,
                        year: cachedDetails.year ?? "",
                        imdbID: cachedDetails.imdbID,
                        type: cachedDetails.type ?? "movie",
                        poster: cachedDetails.poster
                    ))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            checkCollectionStatus()
            if myFilm != nil && cachedDetails == nil && fetchedDetails == nil {
                fetchDetails()
            }
        }
        .onChange(of: myFilmsStore?.films) { _, _ in
            checkCollectionStatus()
        }
    }
    
    private func checkCollectionStatus() {
        guard let store = myFilmsStore, !imdbID.isEmpty else { return }
        myFilm = store.films.first(where: { $0.imdbID == imdbID })
    }
    
    private func fetchDetails() {
        guard !imdbID.isEmpty else { return }
        Task {
            do {
                fetchedDetails = try await OMDBSearchService.shared.getFilm(byID: imdbID)
            } catch {
                print("Failed to fetch film details: \(error)")
            }
        }
    }
}

// MARK: - Constructor for IMDBFilmDetailView

extension IMDBFilmDetailView {
    /// Convenience initializer for search items
    init(searchItem: OMDBSearchItem) {
        self.init(film: IMDBFilm(
            title: searchItem.title,
            imdbID: searchItem.imdbID,
            year: searchItem.year,
            poster: searchItem.poster,
            type: searchItem.type
        ))
    }
}

// MARK: - Previews

#Preview("Film Cell - In Collection") {
    NavigationStack {
        VStack(spacing: 0) {
            FilmCell(cachedDetails: IMDBFilm(
                title: "The Matrix",
                imdbID: "tt0133093",
                year: "1999",
                genre: "Action, Sci-Fi",
                poster: "https://m.media-amazon.com/images/M/MV5BNzQzOTk3OTAtNDQ0Zi00ZTVkLWI0MTEtMDllZjNkYzNjNTc4L2ltYWdlXkEyXkFqcGdeQXVyNjU0OTQ0OTY@._V1_SX300.jpg"
            ))
            
            Divider().padding(.leading, 88)
        }
    }
    .modelContainer(for: [MyFilm.self, IMDBFilm.self], inMemory: true)
}

#Preview("Film Cell - Not In Collection") {
    NavigationStack {
        VStack(spacing: 0) {
            FilmCell(
                searchResult: OMDBSearchItem(
                    title: "Inception",
                    year: "2010",
                    imdbID: "tt1375666",
                    type: "movie",
                    poster: "https://m.media-amazon.com/images/M/MV5BMjAxMzY3NjcxNF5BMl5BanBnXkFtZTcwNTI5OTM0Mw@@._V1_SX300.jpg"
                )
            )
            
            Divider().padding(.leading, 88)
        }
    }
    .modelContainer(for: [MyFilm.self, IMDBFilm.self], inMemory: true)
}

#Preview("Film Cell - Mixed States") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 0) {
                // In collection
                FilmCell(
                    searchResult: OMDBSearchItem(
                        title: "The Shawshank Redemption",
                        year: "1994",
                        imdbID: "tt0111161",
                        type: "movie",
                        poster: "https://m.media-amazon.com/images/M/MV5BMDFkYTc0MGEtZmNhMC00ZDIzLWFmNTEtODM1ZmRlYWMwMWFmXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg"
                    )
                )
                
                Divider().padding(.leading, 88)
                
                // Not in collection
                FilmCell(
                    searchResult: OMDBSearchItem(
                        title: "The Godfather",
                        year: "1972",
                        imdbID: "tt0068646",
                        type: "movie",
                        poster: "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SX300.jpg"
                    )
                )
                
                Divider().padding(.leading, 88)
                
                // In collection (another one)
                FilmCell(
                    searchResult: OMDBSearchItem(
                        title: "Pulp Fiction",
                        year: "1994",
                        imdbID: "tt0110912",
                        type: "movie",
                        poster: "https://m.media-amazon.com/images/M/MV5BNGNhMDIzZTUtNTBlZi00MTRlLWFjM2ItYzViMjE3YzI5MjljXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SX300.jpg"
                    )
                )
            }
        }
    }
    .modelContainer(for: [MyFilm.self, IMDBFilm.self], inMemory: true)
}