//
//  AddToCollectionButton.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//  Updated to follow Apple Human Interface Guidelines
//

import SwiftUI
import SwiftData

/// Compact button component for adding films to collection from search results.
/// Provides visual state feedback, error handling, and accessibility support.
/// 
/// **Component Responsibilities:**
/// - One-tap film addition to user's collection
/// - Real-time collection status checking
/// - Visual state management (default/loading/success/error)
/// - Haptic feedback for iOS
/// - Comprehensive accessibility support
/// 
/// **State Management:**
/// - **isInCollection:** Reflects current collection status
/// - **isLoading:** Shows progress during async operations
/// - **showError/errorMessage:** Handles error display
/// - **showSuccess:** Temporary success state with animation
/// 
/// **UX Design Patterns:**
/// - **Progressive Enhancement:** Works immediately, enhances with collection status
/// - **Visual Feedback:** Clear state transitions with icons and colors
/// - **Error Recovery:** User-friendly error messages with retry capability
/// - **Accessibility First:** Proper labels, hints, and interaction support
/// 
/// **Performance Characteristics:**
/// - Lightweight: Minimal state and computation
/// - Responsive: Immediate UI feedback during operations
/// - Cached: Collection status cached for fast subsequent checks
struct AddToCollectionButton: View {
    /// Search result item to add to collection
    let searchItem: OMDBSearchItem
    
    /// Current collection status (updated on appear and after addition)
    @State private var isInCollection = false
    /// Loading state during async add operation
    @State private var isLoading = false
    /// Error alert presentation state
    @State private var showError = false
    /// User-friendly error message for display
    @State private var errorMessage = ""
    /// Temporary success state with visual feedback
    @State private var showSuccess = false
    
    /// View body implementing the button UI with state-dependent appearance.
    /// **Visual State Machine:**
    /// - **Default:** Plus circle icon (accent color)
    /// - **Loading:** Spinner animation
    /// - **Success/In Collection:** Checkmark icon (success color)
    /// 
    /// **Interaction Design:**
    /// - Button disabled when loading or already in collection
    /// - Plain button style for minimal chrome
    /// - Apple tap target sizing for accessibility
    /// - Alert for error handling
    /// 
    /// **Accessibility Implementation:**
    /// - Dynamic labels based on current state
    /// - Helpful hints explaining button purpose
    /// - Proper disabled state handling
    /// - Voice Control compatibility
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
    
    /// Checks if the film is already in the user's collection.
    /// **Collection Status Check:**
    /// - Called on view appearance for initial state
    /// - Uses MyFilmsManager for centralized collection access
    /// - Updates UI state immediately
    /// 
    /// **Performance:** O(1) lookup via cached collection state
    private func checkCollectionStatus() {
        isInCollection = MyFilmsManager.shared.isFilmInCollection(searchItem.imdbID)
    }
    
    /// Handles button tap with guard against duplicate additions.
    /// **Tap Handling:**
    /// - Guards against adding films already in collection
    /// - Creates async task for collection addition
    /// - Maintains UI responsiveness during operation
    /// 
    /// **Safety:** Double-guard against user tapping disabled button
    private func handleTap() {
        guard !isInCollection else { return }
        
        Task {
            await addToCollection()
        }
    }
    
    /// Performs the async collection addition with comprehensive UX feedback.
    /// **Addition Workflow:**
    /// 1. Set loading state for immediate UI feedback
    /// 2. Call MyFilmsManager to add film to collection
    /// 3. Animate success state transition
    /// 4. Provide haptic feedback (iOS only)
    /// 5. Handle errors with user-friendly messages
    /// 
    /// **UX Enhancements:**
    /// - **Loading State:** Immediate visual feedback
    /// - **Success Animation:** Smooth 300ms transition
    /// - **Haptic Feedback:** Physical confirmation on iOS
    /// - **Error Handling:** Structured error messages
    /// 
    /// **Error Recovery:**
    /// - Maintains button in actionable state on error
    /// - User can retry after dismissing error alert
    /// - Preserves collection status accuracy
    /// 
    /// **Thread Safety:**
    /// - @MainActor ensures UI updates on main thread
    /// - Proper async/await pattern for background work
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

// MARK: - Large Button Variant for Film Detail Views

/// Large button variant optimized for film detail views.
/// Provides more prominent UI with text labels for better context.
/// 
/// **Design Differences from Compact Version:**
/// - Horizontal layout with text labels
/// - BorderedProminent button style for prominence
/// - Larger touch target for easier interaction
/// - More descriptive text for context
/// 
/// **Usage Context:**
/// - Film detail views where space allows
/// - Primary action emphasis needed
/// - Desktop/tablet interfaces
/// - Accessibility-focused layouts
/// 
/// **Component Responsibilities:**
/// - Same core functionality as compact version
/// - Enhanced visual hierarchy for detail views
/// - Improved accessibility with descriptive text
struct AddToCollectionButtonLarge: View {
    /// Complete film data for addition to collection
    let imdbFilm: IMDBFilm
    
    /// Current collection status
    @State private var isInCollection = false
    /// Loading state during async operations
    @State private var isLoading = false
    /// Error alert presentation state
    @State private var showError = false
    /// User-friendly error message
    @State private var errorMessage = ""
    
    /// View body for large button variant with horizontal layout.
    /// **Large Button Design:**
    /// - Horizontal stack with icon and text
    /// - BorderedProminent style for visual emphasis
    /// - Reduced opacity when disabled for clear state indication
    /// - Generous padding for comfortable interaction
    /// 
    /// **State-Dependent Content:**
    /// - **Default:** Plus icon + "Add to Collection" text
    /// - **Loading:** Spinner + no text (cleaner loading state)
    /// - **In Collection:** Checkmark + "In Collection" text
    /// 
    /// **Accessibility Enhancements:**
    /// - Descriptive text provides context without accessibility labels
    /// - Maintains proper labeling for screen readers
    /// - Large touch target meets accessibility guidelines
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
    
    /// Checks collection status using complete film data.
    /// **Large Button Collection Check:**
    /// - Uses IMDBFilm.imdbID for consistency
    /// - Same logic as compact version
    /// - Called on view appearance
    private func checkCollectionStatus() {
        isInCollection = MyFilmsManager.shared.isFilmInCollection(imdbFilm.imdbID)
    }
    
    /// Handles tap interaction for large button variant.
    /// **Interaction Handling:**
    /// - Same guard logic as compact version
    /// - Async task creation for collection addition
    /// - Maintains UI responsiveness
    private func handleTap() {
        guard !isInCollection else { return }
        
        Task {
            await addToCollection()
        }
    }
    
    /// Performs collection addition using complete film data.
    /// **Large Button Addition:**
    /// - Uses IMDBFilm directly (more efficient than search item)
    /// - Same UX patterns as compact version
    /// - No separate success state (direct transition to "In Collection")
    /// - Identical error handling and haptic feedback
    /// 
    /// **Performance Advantage:**
    /// - Complete film data already available
    /// - No additional API calls required
    /// - Faster addition process
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