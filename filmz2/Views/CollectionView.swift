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
        
        if searchText.isEmpty {
            return baseFilms
        } else {
            return baseFilms.filter { film in
                film.title.localizedCaseInsensitiveContains(searchText) ||
                film.director?.localizedCaseInsensitiveContains(searchText) ?? false ||
                film.genres.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
}

struct CollectionFilmCell: View {
    let film: MyFilm
    
    var body: some View {
        HStack(spacing: 12) {
            // Poster
            AsyncImage(url: URL(string: film.posterURL ?? "")) { phase in
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
            
            // Film Info
            VStack(alignment: .leading, spacing: 4) {
                Text(film.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(film.displayYear)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
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
    }
}

// Placeholder for detail view
struct MyFilmDetailView: View {
    let film: MyFilm
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Poster
                if let posterURL = film.posterURL, let url = URL(string: posterURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(2/3, contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(12)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 400)
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Film Info
                VStack(alignment: .leading, spacing: 16) {
                    Text(film.displayYear)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    if !film.genres.isEmpty {
                        GenrePills(film.genres)
                    }
                    
                    // Watch Status
                    HStack {
                        Label(film.watchStatusText, systemImage: film.watched ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(film.watched ? .green : .orange)
                    }
                    
                    // Rating
                    if let rating = film.myRating {
                        HStack {
                            Text("My Rating:")
                            ForEach(1...10, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    if let plot = film.plot {
                        Text("Plot")
                            .font(.headline)
                        Text(plot)
                            .font(.body)
                    }
                    
                    if let notes = film.notes, !notes.isEmpty {
                        Text("My Notes")
                            .font(.headline)
                        Text(notes)
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(film.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#Preview {
    CollectionView()
        .modelContainer(for: MyFilm.self, inMemory: true)
}