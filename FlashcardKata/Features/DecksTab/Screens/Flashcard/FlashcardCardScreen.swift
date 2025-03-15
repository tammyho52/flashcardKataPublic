//
//  ReviewFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View displays an existing flashcard.

import SwiftUI

struct FlashcardCardScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FlashcardFormViewModel
    @State private var showFlashcardFront: Bool = true
    @State private var selectedDeck: Deck?
    @State private var selectedFlashcard: Flashcard?
    @State private var isLoading: Bool = false
    @Binding var selectedFlashcardID: String?
    var selectedDeckID: String?

    var body: some View {
        VStack {
            if isLoading {
                FullScreenProgressScreen()
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
                .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.decks.backgroundGradientColors)
            }
        }
        .toolbar {
            toolbarBackButton(action: { dismiss() })
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("\(selectedDeck?.name ?? "Unknown Deck")")
        .onAppear {
            Task {
                isLoading = true
                defer { isLoading = false }

                if let selectedDeckID, let deck = try await viewModel.fetchDeck(id: selectedDeckID) {
                    selectedDeck = deck
                }
                if let selectedFlashcardID,
                    let flashcard = try await viewModel.fetchFlashcard(id: selectedFlashcardID) {
                    selectedFlashcard = flashcard
                }
            }
        }
    }
}

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
