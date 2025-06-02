//
//  CollectionViewModel.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import Foundation
import SwiftUI
import SwiftData

enum WatchedFilter: String, CaseIterable {
    case all = "All"
    case watched = "Watched"
    case unwatched = "Unwatched"
}

enum SortOption: String, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case yearNewest = "Year (Newest)"
    case yearOldest = "Year (Oldest)"
    case recentlyAdded = "Recently Added"
    case firstAdded = "First Added"
    
    var systemImage: String {
        switch self {
        case .nameAscending, .yearOldest, .firstAdded:
            return "arrow.up"
        case .nameDescending, .yearNewest, .recentlyAdded:
            return "arrow.down"
        }
    }
}

struct CollectionFilter {
    var watchedStatus: WatchedFilter = .all
    var genres: Set<String> = []
    var sortOption: SortOption = .recentlyAdded
}

@MainActor
class CollectionViewModel: ObservableObject {
    @Published var filter = CollectionFilter()
    @Published var searchText = ""
    @Published var availableGenres: [String] = []
    @Published var filmDetailsCache: [String: IMDBFilm] = [:]
    
    var myFilmsStore: MyFilmsStore
    var modelContext: ModelContext
    
    init(myFilmsStore: MyFilmsStore, modelContext: ModelContext) {
        self.myFilmsStore = myFilmsStore
        self.modelContext = modelContext
        Task {
            await loadAvailableGenres()
        }
    }
    
    var filteredAndSortedFilms: [MyFilm] {
        var films = myFilmsStore.films
        
        // Apply watched filter
        switch filter.watchedStatus {
        case .all:
            break
        case .watched:
            films = films.filter { $0.watched }
        case .unwatched:
            films = films.filter { !$0.watched }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            films = films.filter { film in
                // Check if we have cached details for searching
                if let details = filmDetailsCache[film.imdbID] {
                    let searchLower = searchText.lowercased()
                    return details.title.lowercased().contains(searchLower) ||
                           (details.year?.contains(searchText) ?? false) ||
                           (details.director?.lowercased().contains(searchLower) ?? false) ||
                           (details.actors?.lowercased().contains(searchLower) ?? false)
                }
                return false
            }
        }
        
        // Apply genre filter
        if !filter.genres.isEmpty {
            films = films.filter { film in
                guard let details = filmDetailsCache[film.imdbID],
                      let genreString = details.genre else { return false }
                
                let filmGenres = Set(genreString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
                return !filter.genres.isDisjoint(with: filmGenres)
            }
        }
        
        // Apply sort
        films.sort { film1, film2 in
            switch filter.sortOption {
            case .nameAscending:
                let title1 = filmDetailsCache[film1.imdbID]?.title ?? ""
                let title2 = filmDetailsCache[film2.imdbID]?.title ?? ""
                return title1 < title2
                
            case .nameDescending:
                let title1 = filmDetailsCache[film1.imdbID]?.title ?? ""
                let title2 = filmDetailsCache[film2.imdbID]?.title ?? ""
                return title1 > title2
                
            case .yearNewest:
                let year1 = Int(filmDetailsCache[film1.imdbID]?.year ?? "0") ?? 0
                let year2 = Int(filmDetailsCache[film2.imdbID]?.year ?? "0") ?? 0
                return year1 > year2
                
            case .yearOldest:
                let year1 = Int(filmDetailsCache[film1.imdbID]?.year ?? "0") ?? 0
                let year2 = Int(filmDetailsCache[film2.imdbID]?.year ?? "0") ?? 0
                return year1 < year2
                
            case .recentlyAdded:
                return film1.dateAdded > film2.dateAdded
                
            case .firstAdded:
                return film1.dateAdded < film2.dateAdded
            }
        }
        
        return films
    }
    
    func loadFilmDetails(for film: MyFilm) async {
        guard filmDetailsCache[film.imdbID] == nil else { return }
        
        do {
            let details = try await OMDBSearchService.shared.getFilm(byID: film.imdbID)
            await MainActor.run {
                filmDetailsCache[film.imdbID] = details
            }
        } catch {
            print("Failed to load details for \(film.imdbID): \(error)")
        }
    }
    
    func loadAllFilmDetails() async {
        await withTaskGroup(of: Void.self) { group in
            for film in myFilmsStore.films {
                group.addTask {
                    await self.loadFilmDetails(for: film)
                }
            }
        }
        await loadAvailableGenres()
    }
    
    private func loadAvailableGenres() async {
        var genreSet = Set<String>()
        
        for (_, details) in filmDetailsCache {
            if let genreString = details.genre {
                let genres = genreString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                genreSet.formUnion(genres)
            }
        }
        
        await MainActor.run {
            availableGenres = Array(genreSet).sorted()
        }
    }
    
    func clearFilters() {
        filter.genres.removeAll()
        filter.watchedStatus = .all
        searchText = ""
    }
    
    var hasActiveFilters: Bool {
        !filter.genres.isEmpty || filter.watchedStatus != .all || !searchText.isEmpty
    }
}