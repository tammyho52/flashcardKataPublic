//
//  ReadViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view model responsible for managing the read tab, including loading data and managing read settings.

import Foundation

/// A view model for managing the read tab.
@MainActor
final class ReadViewModel: ObservableObject {
    // MARK: - Properties
    @Published var flashcardDisplayModels: [FlashcardDisplayModel] = [] // The flashcard display models to be shown in the read tab.
    @Published var reviewSettings: ReviewSettings = ReviewSettings() // The settings for reviewing flashcards.

    private let databaseManager: DatabaseManagerProtocol

    // MARK: - Constants
    /// Maximum number of flashcards to load for a reading session.
    private let flashcardLimit: Int = 50
    
    // MARK: - Initializer
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }

    // MARK: - Guest User Methods
    /// Check if the user is a guest user.
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }

    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }

    // MARK: - Load Data Methods
    /// Load decks with subdecks for deck selection.
    func loadParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        return try await databaseManager.fetchParentDecksWithSubDecks()
    }
    
    /// Load flashcards for the selected decks for flashcard selection.
    func loadDecksWithFlashcards(deckIDs: Set<String>) async throws -> [(Deck, [Flashcard])] {
        let deckIDsArray = Array(deckIDs)
        return try await databaseManager.fetchDecksWithFlashcards(deckIDs: deckIDsArray)
    }
    
    /// Load flashcards for the selected decks for reading.
    func loadInitialData() async {
        self.flashcardDisplayModels = await loadFlashcardDisplayModels()
    }
    
    /// Clears the selected flashcard IDs.
    func clearSelectedFlashcardIDs() {
        reviewSettings.selectedFlashcardIDs.removeAll()
    }
    
    /// Load flashcards for the selected flashcard IDs for reading.
    private func loadFlashcardDisplayModels() async -> [FlashcardDisplayModel] {
        do {
            return try await databaseManager.loadFlashcardDisplayModels(
                flashcardIDs: reviewSettings.selectedFlashcardIDs,
                flashcardLimit: flashcardLimit,
                displayCardSort: reviewSettings.displayCardSort
            )
        } catch {
            reportError(error)
            return []
        }
    }
}
