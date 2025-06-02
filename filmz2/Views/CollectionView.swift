//
//  CollectionView.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @StateObject private var viewModel: CollectionViewModel = CollectionViewModel()
    
    @State private var showingGenreFilter = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("View", selection: $viewModel.filter.watchedStatus) {
                    Text("All (\(viewModel.totalFilmsCount))").tag(WatchedFilter.all)
                    Text("Watched (\(viewModel.watchedFilmsCount))").tag(WatchedFilter.watched)
                    Text("Unwatched (\(viewModel.unwatchedFilmsCount))").tag(WatchedFilter.unwatched)
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
                    
                if viewModel.films.isEmpty {
                    emptyStateView
                } else if viewModel.filteredAndSortedFilms.isEmpty {
                    filteredEmptyStateView
                } else {
                    filmsList
                }
            }
            .navigationTitle("My Collection")
            .searchable(text: $viewModel.searchText)
            .sheet(isPresented: $showingGenreFilter) {
                GenreFilterSheet(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadFilms()
            }
            .onChange(of: viewModel.filter) { _, _ in
                viewModel.objectWillChange.send()
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
                        MyFilmCell(film: film, filmDetails: viewModel.filmDetailsCache[film.imdbID])
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.leading, 88)
                }
            }
        }
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: MyFilm.self, inMemory: true)
}