//
//  FlashcardCardScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a flashcard for review, allowing the user to flip it.

import SwiftUI

/// A screen that displays a flashcard for review, allowing users to view its front and back.
struct FlashcardCardScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FlashcardFormViewModel
    @State private var showFlashcardFront: Bool = true // Indicates whether the front of the flashcard is shown
    @State private var selectedDeck: Deck? // Used for deck tags to be displayed on the flashcard
    @State private var selectedFlashcard: Flashcard? // The flashcard that is being displayed
    @MainActor @State private var isLoading: Bool = false
    @Binding var selectedFlashcardID: String?
    var selectedDeckID: String?
    
    // MARK: - Body
    var body: some View {
        VStack {
            // Progress view while loading
            if isLoading {
                FullScreenProgressScreen()
                    .edgesIgnoringSafeArea(.bottom)
            // Flashcard view
            } else if let flashcard = selectedFlashcard, let deck = selectedDeck {
                VStack {
                    Spacer()
                    FlashcardCardView(
                        showFlashcardFront: $showFlashcardFront,
                        isFlippable: true,
                        flashcard: flashcard,
                        deckNameLabel: DeckNameLabel(
                            id: deck.id,
                            parentDeckID: deck.parentDeckID,
                            name: deck.name,
                            theme: deck.theme,
                            isSubDeck: deck.isSubdeck
                        )
                    )
                    .padding(20)
                    Spacer()
                }
            }
        }
        .toolbar {
            toolbarBackButton(action: { dismiss() })
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(selectedDeck?.name ?? "Unknown Deck")")
        .applyColoredNavigationBarStyle(
            backgroundGradientColors: Tab.decks.backgroundGradientColors,
            disableBackgroundColor: isLoading
        )
        .onAppear {
            isLoading = true
            Task {
                do {
                    defer { isLoading = false }
                    try await fetchSelectedDeck()
                    try await fetchSelectedFlashcard()
                } catch {
                    reportError(error)
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    /// Fetches the selected deck based on the selected deck ID.
    private func fetchSelectedDeck() async throws {
        if let selectedDeckID,
           let deck = try await viewModel.fetchDeck(id: selectedDeckID) {
            selectedDeck = deck
        }
    }
    
    /// Fetches the selected flashcard based on the selected flashcard ID.
    private func fetchSelectedFlashcard() async throws {
        if let selectedFlashcardID,
           let flashcard = try await viewModel.fetchFlashcard(id: selectedFlashcardID) {
            selectedFlashcard = flashcard
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        FlashcardCardScreen(
            viewModel: FlashcardFormViewModel(databaseManager: MockDatabaseManager()),
            selectedFlashcardID: .constant(Flashcard.sampleFlashcard.id),
            selectedDeckID: Deck.sampleDeck.id
        )
    }
}
#endif
