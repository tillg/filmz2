import Foundation
import Combine
import SwiftUI

@MainActor
class MovieSearchViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [OMDBSearchItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasSearched = false
    
    private let searchService: OMDBSearchServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var currentPage = 1
    private var totalResults = 0
    private var hasMorePages: Bool {
        searchResults.count < totalResults
    }
    
    init(searchService: OMDBSearchServiceProtocol = OMDBSearchService.shared) {
        self.searchService = searchService
        setupSearchDebouncing()
    }
    
    private func setupSearchDebouncing() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query, resetResults: true)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String, resetResults: Bool = false) {
        searchTask?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            hasSearched = false
            errorMessage = nil
            return
        }
        
        if resetResults {
            currentPage = 1
            searchResults = []
            totalResults = 0
        }
        
        searchTask = Task {
            await search(query: query)
        }
    }
    
    private func search(query: String) async {
        isLoading = true
        errorMessage = nil
        hasSearched = true
        
        do {
            let response = try await searchService.searchFilmsRaw(
                query: query,
                year: nil,
                type: nil,
                page: currentPage
            )
            
            if Task.isCancelled { return }
            
            if let results = response.search {
                if currentPage == 1 {
                    searchResults = results
                } else {
                    searchResults.append(contentsOf: results)
                }
                totalResults = Int(response.totalResults ?? "0") ?? 0
            } else {
                searchResults = []
                totalResults = 0
            }
            errorMessage = nil
        } catch let error as OMDBError {
            if Task.isCancelled { return }
            handleError(error)
        } catch {
            if Task.isCancelled { return }
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    private func handleError(_ error: OMDBError) {
        switch error {
        case .movieNotFound:
            errorMessage = nil // This is handled by empty state
            searchResults = []
        case .invalidAPIKey:
            errorMessage = "Invalid API key. Please check your configuration."
        case .dailyLimitExceeded:
            errorMessage = "Daily API limit exceeded. Please try again tomorrow."
        case .networkError(let underlyingError):
            errorMessage = "Network error: \(underlyingError.localizedDescription)"
        case .decodingError(let decodingError):
            errorMessage = "Failed to process search results: \(decodingError.localizedDescription)"
        case .unknownError(let message):
            errorMessage = message
        case .invalidResponse:
            errorMessage = "Invalid response from server"
        }
    }
    
    func loadMoreIfNeeded(currentItem: OMDBSearchItem?) {
        guard let currentItem = currentItem,
              !isLoading,
              hasMorePages else { return }
        
        let thresholdIndex = searchResults.index(searchResults.endIndex, offsetBy: -3)
        if let itemIndex = searchResults.firstIndex(where: { $0.imdbID == currentItem.imdbID }),
           itemIndex >= thresholdIndex {
            currentPage += 1
            performSearch(query: searchQuery)
        }
    }
    
    func selectFilm(_ result: OMDBSearchItem) async -> IMDBFilm? {
        do {
            return try await searchService.getFilmDetails(imdbID: result.imdbID)
        } catch {
            errorMessage = "Failed to load movie details"
            return nil
        }
    }
    
    func retry() {
        performSearch(query: searchQuery, resetResults: true)
    }
}