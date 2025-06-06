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
                .padding(.bottom, DesignTokens.Spacing.small.rawValue)
                    
                // Genre Filter Row
                HStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignTokens.Spacing.extraSmall.rawValue) {
                            genreFilterPill(text: "All Genres", isSelected: viewModel.filter.genres.isEmpty) {
                                viewModel.clearGenreFilter()
                            }
                            
                            ForEach(viewModel.availableGenres, id: \.self) { genre in
                                genreFilterPill(text: genre, isSelected: viewModel.filter.genres.contains(genre)) {
                                    viewModel.toggleGenre(genre)
                                }
                            }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.small.rawValue)
                    }
                    
                    // Sort Button
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
                        Image(systemName: "arrow.up.arrow.down")
                            .font(DesignTokens.Typography.title3)
                            .foregroundColor(DesignTokens.Colors.accent)
                            .padding(.trailing, DesignTokens.Spacing.small.rawValue)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, DesignTokens.Spacing.extraSmall.rawValue)
                    
                if viewModel.films.isEmpty {
                    emptyStateView
                } else if viewModel.filteredAndSortedFilms.isEmpty {
                    filteredEmptyStateView
                } else {
                    filmsList
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .searchable(text: $viewModel.searchText)
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
    
    // MARK: - Helper Functions
    
    private func genreFilterPill(text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(DesignTokens.Typography.subheadline)
                .foregroundColor(isSelected ? .white : DesignTokens.Colors.primary)
                .padding(.horizontal, DesignTokens.Spacing.small.rawValue)
                .padding(.vertical, DesignTokens.Spacing.extraSmall.rawValue)
                .background(
                    Capsule()
                        .fill(isSelected ? DesignTokens.Colors.accent : DesignTokens.Colors.secondaryFill)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(text) filter")
        .accessibilityHint(isSelected ? "Currently selected. Tap to deselect" : "Tap to filter by \(text)")
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: MyFilm.self, inMemory: true)
}