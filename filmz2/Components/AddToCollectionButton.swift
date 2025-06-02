//
//  AddToCollectionButton.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

import SwiftUI
import SwiftData

struct AddToCollectionButton: View {
    let searchItem: OMDBSearchItem
    @Environment(\.myFilmsStore) private var myFilmsStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var isInCollection = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        Button(action: handleTap) {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 24, height: 24)
            } else if isInCollection || showSuccess {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            } else {
                Image(systemName: "plus.circle")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
        .disabled(isInCollection || isLoading)
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            checkCollectionStatus()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func checkCollectionStatus() {
        guard let store = myFilmsStore else { return }
        isInCollection = store.isFilmInCollection(searchItem.imdbID)
    }
    
    private func handleTap() {
        guard !isInCollection else { return }
        
        Task {
            await addToCollection()
        }
    }
    
    @MainActor
    private func addToCollection() async {
        isLoading = true
        
        do {
            // If we don't have a store in the environment, create one
            let store = myFilmsStore ?? MyFilmsStore(modelContext: modelContext)
            
            _ = try await store.addFilm(from: searchItem)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccess = true
                isInCollection = true
            }
            
            // Haptic feedback
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            #endif
            
        } catch let error as MyFilmsStoreError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Failed to add film: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
}

// MARK: - Simplified Version for Film Detail

struct AddToCollectionButtonLarge: View {
    let imdbFilm: IMDBFilm
    @Environment(\.myFilmsStore) private var myFilmsStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var isInCollection = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Button(action: handleTap) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if isInCollection {
                    Image(systemName: "checkmark.circle.fill")
                    Text("In Collection")
                } else {
                    Image(systemName: "plus.circle")
                    Text("Add to Collection")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isInCollection ? Color.green : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .disabled(isInCollection || isLoading)
        .onAppear {
            checkCollectionStatus()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func checkCollectionStatus() {
        guard let store = myFilmsStore else { return }
        isInCollection = store.isFilmInCollection(imdbFilm.imdbID)
    }
    
    private func handleTap() {
        guard !isInCollection else { return }
        
        Task {
            await addToCollection()
        }
    }
    
    @MainActor
    private func addToCollection() async {
        isLoading = true
        
        do {
            let store = myFilmsStore ?? MyFilmsStore(modelContext: modelContext)
            _ = try await store.addFilm(from: imdbFilm)
            
            withAnimation(.easeInOut(duration: 0.3)) {
                isInCollection = true
            }
            
            // Haptic feedback
            #if os(iOS)
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            #endif
            
        } catch let error as MyFilmsStoreError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Failed to add film: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
}