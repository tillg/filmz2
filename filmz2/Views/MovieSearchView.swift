import SwiftUI

struct MovieSearchView: View {
    @StateObject private var viewModel = MovieSearchViewModel()
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                
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
        }
        .onAppear {
            isSearchFieldFocused = true
        }
    }
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search movies...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    #if os(iOS)
                    .autocapitalization(.none)
                    #endif
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    .focused($isSearchFieldFocused)
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchResults, id: \.imdbID) { result in
                    VStack(spacing: 0) {
                        FilmCell(searchResult: result)
                        
                        Divider()
                            .padding(.leading, 88)
                    }
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentItem: result)
                    }
                }
                
                if viewModel.isLoading && !viewModel.searchResults.isEmpty {
                    ProgressView()
                        .padding()
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Searching...")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No movies found")
                .font(.headline)
            Text("Try searching with different keywords")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
    
    private var shortQueryView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "text.cursor")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Keep typing...")
                .font(.headline)
            Text("Enter at least 3 characters to search")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.retry()
            }) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    MovieSearchView()
}