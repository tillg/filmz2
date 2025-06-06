import SwiftUI

/// Movie search view following Apple Human Interface Guidelines
/// Uses native search patterns and proper spacing/typography
struct MovieSearchView: View {
    @StateObject private var viewModel = MovieSearchViewModel()
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.searchResults.isEmpty {
                    loadingView
                } else if viewModel.searchResults.isEmpty && viewModel.hasSearched {
                    if !viewModel.searchQuery.isEmpty && viewModel.searchQuery.count < 3 {
                        shortQueryView
                    } else {
                        emptyStateView
                    }
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Search Movies")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .searchable(text: $viewModel.searchQuery, prompt: "Search movies...")
            .searchSuggestions {
                if viewModel.searchQuery.isEmpty {
                    Text("Batman").searchCompletion("Batman")
                    Text("Star Wars").searchCompletion("Star Wars")
                    Text("Lord of the Rings").searchCompletion("Lord of the Rings")
                }
            }
        }
    }
    
    
    private var searchResultsList: some View {
        List {
            ForEach(viewModel.searchResults, id: \.imdbID) { result in
                NavigationLink(destination: IMDBFilmDetailView(searchItem: result)) {
                    MovieSearchResultCellWithCache(result: result)
                        .padding(.vertical, DesignTokens.Spacing.extraSmall.rawValue)
                }
                .onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: result)
                }
            }
            
            if viewModel.isLoading && !viewModel.searchResults.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.vertical, DesignTokens.Spacing.small.rawValue)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
    
    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.small.rawValue) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching...")
                .font(DesignTokens.Typography.headline)
                .foregroundColor(DesignTokens.Colors.secondary)
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No movies found",
            systemImage: "magnifyingglass",
            description: Text("Try searching with different keywords")
        )
    }
    
    private var shortQueryView: some View {
        ContentUnavailableView(
            "Keep typing...",
            systemImage: "text.cursor",
            description: Text("Enter at least 3 characters to search")
        )
    }
    
    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry", action: viewModel.retry)
                .buttonStyle(BorderedProminentButtonStyle())
        }
    }
}

#Preview {
    MovieSearchView()
}