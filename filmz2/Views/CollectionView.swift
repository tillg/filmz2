//
//  CollectionView.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.myFilmsStore) private var myFilmsStore
    
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let store = myFilmsStore {
                    // Segmented Control
                    Picker("View", selection: $selectedTab) {
                        Text("All (\(store.totalFilmsCount))").tag(0)
                        Text("Watched (\(store.watchedFilmsCount))").tag(1)
                        Text("Unwatched (\(store.unwatchedFilmsCount))").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if store.films.isEmpty {
                        emptyStateView
                    } else {
                        filmsList
                    }
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("My Collection")
            .searchable(text: $searchText)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "film.stack")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Films Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Search for films and add them to your collection")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var filmsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredFilms) { film in
                    NavigationLink(destination: MyFilmDetailView(film: film)) {
                        CollectionFilmCell(film: film)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 88)
                }
            }
        }
    }
    
    private var filteredFilms: [MyFilm] {
        guard let store = myFilmsStore else { return [] }
        
        let baseFilms: [MyFilm]
        
        switch selectedTab {
        case 1:
            baseFilms = store.films.filter { $0.watched }
        case 2:
            baseFilms = store.films.filter { !$0.watched }
        default:
            baseFilms = store.films
        }
        
        // For now, return all films when searching since we don't have cached data
        // In a full implementation, we could maintain a search index
        return baseFilms
    }
}

struct CollectionFilmCell: View {
    let film: MyFilm
    @State private var filmDetails: IMDBFilm?
    @State private var isLoading = true
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster
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
                .frame(width: 60, height: 90)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 90)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.5)
                    )
            }
            
            // Film Info
            VStack(alignment: .leading, spacing: 4) {
                if let details = filmDetails {
                    Text(details.title)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text(details.displayYear ?? "Unknown Year")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Rating or Watch Status
                if film.watched {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        if let rating = film.ratingText {
                            Text("• \(rating)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("Not watched")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .task {
            do {
                filmDetails = try await OMDBSearchService.shared.getFilm(byID: film.imdbID)
            } catch {
                // Keep loading state or show error
                print("Failed to load film details: \(error)")
            }
        }
    }
}


#Preview {
    CollectionView()
        .modelContainer(for: MyFilm.self, inMemory: true)
}