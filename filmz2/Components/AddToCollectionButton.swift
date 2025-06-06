//
//  AddToCollectionButton.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//  Updated to follow Apple Human Interface Guidelines
//

import SwiftUI
import SwiftData

struct AddToCollectionButton: View {
    let searchItem: OMDBSearchItem
    
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
                    .font(DesignTokens.Typography.title2)
                    .foregroundColor(DesignTokens.Colors.success)
            } else {
                Image(systemName: "plus.circle")
                    .font(DesignTokens.Typography.title2)
                    .foregroundColor(DesignTokens.Colors.accent)
            }
        }
        .disabled(isInCollection || isLoading)
        .buttonStyle(.plain)
        .appleTapTarget()
        .accessibilityLabel(isInCollection ? "Already in collection" : "Add to collection")
        .accessibilityHint(isInCollection ? "Film is already saved" : "Add this film to your collection")
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
        isInCollection = MyFilmsManager.shared.isFilmInCollection(searchItem.imdbID)
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
            _ = try await MyFilmsManager.shared.addFilm(from: searchItem)
            
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
            .padding(.horizontal, DesignTokens.Spacing.small.rawValue)
            .padding(.vertical, DesignTokens.Spacing.extraSmall.rawValue)
        }
        .disabled(isInCollection || isLoading)
        .buttonStyle(BorderedProminentButtonStyle())
        .opacity(isInCollection ? 0.6 : 1.0)
        .appleTapTarget()
        .accessibilityLabel(isInCollection ? "Film in collection" : "Add to collection")
        .accessibilityHint(isInCollection ? "This film is already in your collection" : "Add this film to your collection")
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
        isInCollection = MyFilmsManager.shared.isFilmInCollection(imdbFilm.imdbID)
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
            _ = try await MyFilmsManager.shared.addFilm(from: imdbFilm)
            
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