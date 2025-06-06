//
//  CollectionView.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//  Updated to follow Apple Human Interface Guidelines
//

import SwiftUI
import SwiftData

/// Collection view displaying user's film collection
/// Updated to follow Apple Human Interface Guidelines with proper navigation patterns
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
                .pickerStyle(.segmented)
                .padding(.horizontal, DesignTokens.Spacing.small.rawValue)
                .padding(.top, DesignTokens.Spacing.small.rawValue)
                    
                    // Filter and Sort Bar
                    HStack(spacing: DesignTokens.Spacing.small.rawValue) {
                        // Genre Filter
                        Button(action: { showingGenreFilter.toggle() }) {
                            HStack(spacing: 4) {
                                Text(viewModel.filter.genres.isEmpty ? "All Genres" : "\(viewModel.filter.genres.count) Genres")
                                    .font(DesignTokens.Typography.subheadline)
                                Image(systemName: "chevron.down")
                                    .font(DesignTokens.Typography.caption)
                            }
                            .padding(.horizontal, DesignTokens.Spacing.small.rawValue)
                            .padding(.vertical, DesignTokens.Spacing.extraSmall.rawValue)
                        }
                        .buttonStyle(BorderedButtonStyle())
                        
                        Spacer()
                        
                        // Sort Menu
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: { viewModel.filter.sortOption = option }) {
                                    Label {
                                        Text(option.rawValue)
                                    } icon: {
                                        if viewModel.filter.sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Label("Sort", systemImage: viewModel.filter.sortOption.systemImage)
                                .font(DesignTokens.Typography.subheadline)
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    .padding(.horizontal, DesignTokens.Spacing.small.rawValue)
                    .padding(.bottom, DesignTokens.Spacing.extraSmall.rawValue)
                    
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
        ContentUnavailableView {
            Label("No Films Yet", systemImage: "film.stack")
        } description: {
            Text("Search for films and add them to your collection")
        }
    }
    
    private var filteredEmptyStateView: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("No films match your current filters")
        } actions: {
            if viewModel.hasActiveFilters {
                Button("Clear Filters", action: viewModel.clearFilters)
                    .buttonStyle(BorderedButtonStyle())
            }
        }
    }
    
    private var filmsList: some View {
        List {
            ForEach(viewModel.filteredAndSortedFilms) { film in
                NavigationLink(destination: MyFilmDetailView(film: film)) {
                    MyFilmCell(film: film, filmDetails: viewModel.filmDetailsCache[film.imdbID])
                        .padding(.vertical, DesignTokens.Spacing.extraSmall.rawValue)
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: MyFilm.self, inMemory: true)
}