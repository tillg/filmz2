import SwiftUI
import SwiftData

struct CacheView: View {
    @State private var cachedFilms: [CachedIMDBFilm] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Total cached films")
                        Spacer()
                        Text("\(cachedFilms.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Cached Films") {
                    ForEach(cachedFilms) { film in
                        CachedFilmRow(film: film)
                    }
                    .onDelete(perform: deleteFilms)
                }
            }
            .navigationTitle("Cache")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Clear All") {
                        clearCache()
                    }
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                loadCache()
            }
        }
    }
    
    private func loadCache() {
        cachedFilms = CacheManager.shared.fetchAllFilms()
    }
    
    private func deleteFilms(at offsets: IndexSet) {
        // Note: This would need to be implemented in CacheManager
        // For now, just refresh the list
        loadCache()
    }
    
    private func clearCache() {
        CacheManager.shared.clearCache()
        cachedFilms = []
    }
}

struct CachedFilmRow: View {
    let film: CachedIMDBFilm
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(film.title)
                    .font(.headline)
                Spacer()
                if let rating = film.imdbRating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(rating)/10")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Text(film.imdbID)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if film.isStale {
                    Text("Stale")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            HStack {
                Text("Cached: \(film.lastFetched.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if let year = film.year {
                    Text("• \(year)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                if let type = film.type {
                    Text("• \(type.capitalized)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CacheView()
        .modelContainer(for: [CachedIMDBFilm.self], inMemory: true)
}