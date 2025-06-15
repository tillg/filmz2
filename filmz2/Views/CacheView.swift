import SwiftUI
import SwiftData

struct CacheView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cachedFilms: [IMDBFilm] = []
    @State private var filmManager: IMDBFilmManager?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Total cached films")
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("\(cachedFilms.count)")
                                .foregroundColor(DesignTokens.Colors.secondary)
                        }
                    }
                }
                
                Section("Cached Films") {
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading cached films...")
                            Spacer()
                        }
                        .padding()
                    } else {
                        ForEach(cachedFilms) { film in
                            CachedFilmRow(film: film)
                        }
                        .onDelete(perform: deleteFilms)
                    }
                }
            }
            .navigationTitle("Cache")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Clear All") {
                        Task {
                            await clearCache()
                        }
                    }
                    .foregroundColor(DesignTokens.Colors.error)
                    .disabled(isLoading)
                }
            }
            .onAppear {
                setupFilmManager()
            }
        }
    }
    
    private func setupFilmManager() {
        if filmManager == nil {
            filmManager = IMDBFilmManager(modelContainer: modelContext.container)
            Task {
                await loadCache()
            }
        }
    }
    
    private func loadCache() async {
        guard let filmManager = filmManager else { return }
        
        isLoading = true
        do {
            let films = try await filmManager.fetchAllFilms()
            await MainActor.run {
                cachedFilms = films
                isLoading = false
            }
        } catch {
            print("CacheView: Failed to load cached films: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func deleteFilms(at offsets: IndexSet) {
        // TODO: Implement individual film deletion in IMDBFilmManager
        // For now, just refresh the list
        Task {
            await loadCache()
        }
    }
    
    private func clearCache() async {
        guard let filmManager = filmManager else { return }
        
        isLoading = true
        do {
            let removed = try await filmManager.clearAllFilms()
            print("CacheView: Cleared \(removed) films from cache")
            
            await MainActor.run {
                cachedFilms = []
                isLoading = false
            }
        } catch {
            print("CacheView: Failed to clear cache: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct CachedFilmRow: View {
    let film: IMDBFilm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(film.title)
                    .font(DesignTokens.Typography.headline)
                Spacer()
                if let rating = film.imdbRating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(DesignTokens.Typography.caption)
                        Text("\(rating)/10")
                            .font(DesignTokens.Typography.caption)
                            .foregroundColor(DesignTokens.Colors.secondary)
                    }
                }
            }
            
            HStack {
                Text(film.imdbID)
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(DesignTokens.Colors.secondary)
                
                Spacer()
                
                if film.isStale {
                    Text("Stale")
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(DesignTokens.Colors.warning)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(DesignTokens.Colors.warning.opacity(0.2))
                        .appleCornerRadius(.small)
                }
            }
            
            HStack {
                Text("Cached: \(film.lastFetched.formatted(date: .abbreviated, time: .shortened))")
                    .font(DesignTokens.Typography.caption2)
                    .foregroundColor(DesignTokens.Colors.secondary)
                
                if let year = film.year {
                    Text("• \(year)")
                        .font(DesignTokens.Typography.caption2)
                        .foregroundColor(DesignTokens.Colors.secondary)
                }
                
                if let type = film.type {
                    Text("• \(type.capitalized)")
                        .font(DesignTokens.Typography.caption2)
                        .foregroundColor(DesignTokens.Colors.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CacheView()
        .modelContainer(for: [IMDBFilm.self], inMemory: true)
}