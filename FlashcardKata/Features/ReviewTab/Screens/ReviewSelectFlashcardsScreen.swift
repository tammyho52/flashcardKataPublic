//
//  ReviewSelectFlashcardsScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view for selecting flashcards before starting the review session

import SwiftUI

/// A view for selecting flashcards to include in the review session.
struct ReviewSelectFlashcardsScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReviewViewModel
    @State private var selectedDeckIDs: Set<String> = []
    @State private var selectedFlashcardIDs: Set<String> = []
    @State private var isLoading = false
    @State private var errorToast: Toast?
    @Binding var showSelectDecksView: Bool
    @Binding var showSelectFlashcardsView: Bool

    let previousSelectedDeckIDs: Set<String>

    // MARK: - Body
    var body: some View {
        SelectFlashcardsView(
            selectedDeckIDs: $selectedDeckIDs,
            selectedFlashcardIDs: $selectedFlashcardIDs,
            isLoading: $isLoading,
            loadDecksWithFlashcards: loadDecksWithFlashcards,
            sectionTitle: "Review Flashcards"
        )
        .accessibilityIdentifier("selectReviewFlashcardsView")
        .navigationTitle("Flashcard Selection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .addToast(toast: $errorToast)
        .toolbar {
            toolbarBackButton(isDisabled: isLoading) {
                showSelectFlashcardsView = false
            }
            toolbarTextButton(
                isDisabled: isLoading,
                action: {
                    viewModel.reviewSettings.selectedFlashcardIDs = selectedFlashcardIDs
                    showSelectFlashcardsView = false
                    showSelectDecksView = false
                },
                text: "Done",
                placement: .topBarTrailing,
                accessibilityIdentifier: "toolbarDoneButton"
            )
        }
    }
    
    // MARK: - Private Methods
    /// Loads decks with flashcards based on the selected deck IDs.
    private func loadDecksWithFlashcards() async -> [(Deck, [Flashcard])] {
        do {
            return try await viewModel.loadDecksWithFlashcards(deckIDs: previousSelectedDeckIDs)
        } catch {
            updateErrorToast(error, errorToast: $errorToast)
            reportError(error)
            return []
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let deckIDs: [String] = Deck.sampleDeckArray.map(\.id)
    let subdeckIDs: [String] = Deck.sampleSubdeckArray.map(\.id)
    let combinedDeckIDs = deckIDs + subdeckIDs

    ReviewSelectFlashcardsScreen(
        viewModel: ReviewViewModel(databaseManager: MockDatabaseManager()),
        showSelectDecksView: .constant(false),
        showSelectFlashcardsView: .constant(false),
        previousSelectedDeckIDs: Set(combinedDeckIDs)
    )
}
#endif
