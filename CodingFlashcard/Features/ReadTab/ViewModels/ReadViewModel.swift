//
//  ReadViewModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation

@MainActor
final class ReadViewModel: ObservableObject {
    @Published var flashcardDisplayModels: [FlashcardDisplayModel] = []
    @Published var reviewSettings: ReviewSettings = ReviewSettings()
    
    private let databaseManager: DatabaseManagerProtocol
    
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }
    
    // MARK: - Guest Methods
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }
    
    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }
    
    // MARK: - Read Methods
    
    func loadParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        return try await databaseManager.loadParentDecksWithSubDecks()
    }
    
    func loadDecksWithFlashcards(deckIDs: Set<String>) async throws -> [(Deck, [Flashcard])] {
        let deckIDsArray = Array(deckIDs)
        return try await databaseManager.loadDecksWithFlashcards(deckIDs: deckIDsArray)
    }
    
    func loadFlashcardDisplayModels() async {
        do {
            var flashcards: [Flashcard] = []
            if reviewSettings.selectedFlashcardIDs.isEmpty {
                flashcards = try await databaseManager.fetchAllFlashcards(flashcardLimit: 50)
            } else {
                flashcards = try await databaseManager.fetchFlashcards(ids: Array(reviewSettings.selectedFlashcardIDs))
            }
            
            var flashcardDisplayModels: [FlashcardDisplayModel] = []
            for flashcard in flashcards {
                try Task.checkCancellation()
                if let deck = try await databaseManager.fetchDeck(for: flashcard.deckID) {
                    flashcardDisplayModels.append(FlashcardDisplayModel(flashcard: flashcard, deckNameLabel: deck.deckNameLabel))
                }
            }
            
            flashcardDisplayModels = switch reviewSettings.displayCardSort {
                case .lastUpdated:
                    flashcardDisplayModels.sorted(by: { $0.flashcard.updatedDate > $1.flashcard.updatedDate })
                case .byDeck:
                    flashcardDisplayModels.sorted(by: { ($0.deckNameLabel.id, $0.flashcard.updatedDate) > ($1.deckNameLabel.id, $1.flashcard.updatedDate) })
                case .shuffle:
                    flashcardDisplayModels.shuffled()
            }
            self.flashcardDisplayModels = flashcardDisplayModels
        } catch {
            self.flashcardDisplayModels = []
        }
    }
    
    func clearSelectedFlashcardIDs() {
        reviewSettings.selectedFlashcardIDs.removeAll()
    }
}
