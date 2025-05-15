//
//  ReadSelectFlashcardsScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view for selecting flashcards for the Read screen.

import SwiftUI

/// A view for selecting flashcards for reading.
struct ReadSelectFlashcardsScreen: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ReadViewModel
    @State private var selectedDeckIDs: Set<String> = []
    @State private var isLoading = false
    @State private var errorToast: Toast?
    @Binding var selectedFlashcardIDs: Set<String> // Tracks selected flashcard IDs.
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
            sectionTitle: "Read Flashcards"
        )
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
                placement: .topBarTrailing
            )
        }
    }
    
    // MARK: - Private Methods
    private func loadDecksWithFlashcards() async -> [(Deck, [Flashcard])] {
        do {
            return try await viewModel.loadDecksWithFlashcards(deckIDs: previousSelectedDeckIDs)
        } catch {
            updateErrorToast(error, errorToast: $errorToast)
            reportError(error)
        }
        return []
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let deckIDs: [String] = Deck.sampleDeckArray.map(\.id)
    let subdeckIDs: [String] = Deck.sampleSubdeckArray.map(\.id)
    let combinedDeckIDs = deckIDs + subdeckIDs

    NavigationStack {
        ReadSelectFlashcardsScreen(
            viewModel: ReadViewModel(databaseManager: MockDatabaseManager()),
            selectedFlashcardIDs: .constant(Set(Flashcard.sampleFlashcardArray.map { $0.id })),
            showSelectDecksView: .constant(false),
            showSelectFlashcardsView: .constant(true),
            previousSelectedDeckIDs: Set(combinedDeckIDs)
        )
    }
    .font(.customBody)
}
#endif
