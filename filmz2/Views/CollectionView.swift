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
    @StateObject private var viewModel: CollectionViewModel
    
    @State private var showingGenreFilter = false
    
    init() {
        // Create a temporary view model - will be replaced with proper context
        let tempContainer = try! ModelContainer(for: MyFilm.self)
        let tempContext = ModelContext(tempContainer)
        let tempStore = MyFilmsStore(modelContext: tempContext)
        self._viewModel = StateObject(wrappedValue: CollectionViewModel(myFilmsStore: tempStore, modelContext: tempContext))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let store = myFilmsStore {
                    // Segmented Control
                    Picker("View", selection: $viewModel.filter.watchedStatus) {
                        Text("All (\(store.totalFilmsCount))").tag(WatchedFilter.all)
                        Text("Watched (\(store.watchedFilmsCount))").tag(WatchedFilter.watched)
                        Text("Unwatched (\(store.unwatchedFilmsCount))").tag(WatchedFilter.unwatched)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Filter and Sort Bar
                    HStack(spacing: 12) {
                        // Genre Filter
                        Button(action: { showingGenreFilter.toggle() }) {
                            HStack(spacing: 4) {
                                Text(viewModel.filter.genres.isEmpty ? "All Genres" : "\(viewModel.filter.genres.count) Genres")
                                    .font(.subheadline)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.filter.genres.isEmpty ? Color.secondary.opacity(0.1) : Color.accentColor.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        // Sort Menu
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: { viewModel.filter.sortOption = option }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if viewModel.filter.sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("Sort")
                                    .font(.subheadline)
                                Image(systemName: viewModel.filter.sortOption.systemImage)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    if store.films.isEmpty {
                        emptyStateView
                    } else if viewModel.filteredAndSortedFilms.isEmpty {
                        filteredEmptyStateView
                    } else {
                        filmsList
                    }
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("My Collection")
            .searchable(text: $viewModel.searchText)
            .sheet(isPresented: $showingGenreFilter) {
                GenreFilterSheet(viewModel: viewModel)
            }
            .onAppear {
                if let store = myFilmsStore {
                    viewModel.myFilmsStore = store
                    viewModel.modelContext = modelContext
                    Task {
                        await viewModel.loadAllFilmDetails()
                    }
                }
            }
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
    
    private var filteredEmptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("No films match your current filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if viewModel.hasActiveFilters {
                Button("Clear Filters") {
                    viewModel.clearFilters()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
    }
    
    private var filmsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredAndSortedFilms) { film in
                    NavigationLink(destination: MyFilmDetailView(film: film)) {
                        CollectionFilmCell(film: film, filmDetails: viewModel.filmDetailsCache[film.imdbID])
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 88)
                }
            }
        }
    }
}

struct CollectionFilmCell: View {
    let film: MyFilm
    let filmDetails: IMDBFilm?
    
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
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(details.displayYear ?? "Unknown Year")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Genre Pills
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
    }
}


#Preview {
    CollectionView()
        .modelContainer(for: MyFilm.self, inMemory: true)
}