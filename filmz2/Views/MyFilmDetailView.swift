//
//  MyFilmDetailView.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import SwiftUI
import SwiftData

struct MyFilmDetailView: View {
    @Bindable var film: MyFilm
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showDeleteAlert = false
    @State private var showDatePicker = false
    @State private var filmDetails: IMDBFilm?
    @State private var isLoading = true
    @State private var loadError: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading film details...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = loadError {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    Text("Failed to load film details")
                        .font(.title2)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Retry") {
                        Task {
                            await loadFilmDetails()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if let details = filmDetails {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Film Poster Section
                        FilmPosterSection(
                            posterURL: details.posterURL,
                            title: details.title
                        )
                        
                        // Title and Basic Info
                        titleSection(for: details)
                        
                        // User Data Section
                        userDataSection
                        
                        // Ratings Section
                        ratingsSection(for: details)
                        
                        // Film Info Section
                        FilmMetadataSection(
                            genres: details.genreList,
                            director: details.director,
                            actors: details.actors,
                            writers: details.writers,
                            released: details.released,
                            runtime: details.runtime,
                            language: details.language,
                            country: details.country,
                            awards: details.awards
                        )
                        
                        // Plot Section
                        if let plot = details.plot {
                            ExpandablePlot(plot: plot)
                        }
                        
                        // Cast & Crew Section
                        FilmCastAndCrewSection(
                            actors: details.actors,
                            writers: details.writers
                        )
                        
                        // Delete Button
                        deleteButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                .navigationTitle(details.title)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
            }
        }
        .task {
            await loadFilmDetails()
        }
        .alert("Delete Film", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteFilm()
            }
        } message: {
            Text("Are you sure you want to remove this film from your collection?")
        }
    }
    
    // MARK: - View Components
    
    private func titleSection(for details: IMDBFilm) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if let year = details.year {
                    Text(year)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                if let rated = details.rated {
                    Text(rated)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if film.watched {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.green)
            }
        }
    }
    
    private var userDataSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("My Data")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Watch Status
            watchStatusSection
            
            // Rating - only show when watched
            if film.watched {
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Rating")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    StarRatingView(rating: $film.myRating)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            
            // Audience Type
            audienceSection
            
            // Recommended By
            recommendedBySection
            
            // My Notes - moved here from separate section
            VStack(alignment: .leading, spacing: 8) {
                Text("My Notes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextEditor(text: Binding(
                    get: { film.notes ?? "" },
                    set: { 
                        film.notes = $0.isEmpty ? nil : $0
                        saveChanges()
                    }
                ))
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.3), value: film.watched)
    }
    
    private var watchStatusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $film.watched) {
                Text("Watched")
                    .font(.subheadline)
            }
            .onChange(of: film.watched) { oldValue, newValue in
                if newValue && film.dateWatched == nil {
                    film.dateWatched = Date()
                }
                saveChanges()
            }
            
            if film.watched {
                DatePicker(
                    "Date Watched",
                    selection: Binding(
                        get: { film.dateWatched ?? Date() },
                        set: { 
                            film.dateWatched = $0
                            saveChanges()
                        }
                    ),
                    in: ...Date(),
                    displayedComponents: .date
                )
                .font(.subheadline)
            }
        }
    }
    
    private var audienceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Audience")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Audience", selection: $film.audience) {
                Text("Not Set").tag(nil as AudienceType?)
                Text("Me alone").tag(AudienceType.meAlone as AudienceType?)
                Text("Me and partner").tag(AudienceType.meAndPartner as AudienceType?)
                Text("Family").tag(AudienceType.family as AudienceType?)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: film.audience) { _, _ in
                saveChanges()
            }
        }
    }
    
    private var recommendedBySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended by")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Who recommended this?", text: Binding(
                get: { film.recommendedBy ?? "" },
                set: { 
                    film.recommendedBy = $0.isEmpty ? nil : $0
                    saveChanges()
                }
            ))
            .textFieldStyle(.roundedBorder)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete from Collection")
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Actions
    
    private func loadFilmDetails() async {
        isLoading = true
        loadError = nil
        
        do {
            filmDetails = try await OMDBSearchService.shared.getFilm(byID: film.imdbID)
            isLoading = false
        } catch {
            loadError = error.localizedDescription
            isLoading = false
        }
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
    
    private func deleteFilm() {
        modelContext.delete(film)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete film: \(error)")
        }
    }
    
    // MARK: - Rating Helpers
    
    @ViewBuilder
    private func ratingsSection(for details: IMDBFilm) -> some View {
        let hasRatings = (details.imdbRating != nil && details.imdbRating != "N/A") ||
                        details.rottenTomatoesRating != nil ||
                        film.myRating != nil
        
        if hasRatings {
            VStack(alignment: .leading, spacing: 12) {
                Text("Ratings")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                RatingsRow(
                    film: details,
                    myRating: film.myRating
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyFilmDetailView(film: MyFilm(imdbID: "tt0133093"))
    }
    .modelContainer(for: MyFilm.self, inMemory: true)
}