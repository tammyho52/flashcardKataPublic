//
//  FlashcardFormViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view model responsible for managing the creation, updating, and deletion of flashcards.

import Foundation

/// A view model for managing flashcard operations.
final class FlashcardFormViewModel: ObservableObject {
    // MARK: - Properties
    @Published var initialFlashcard: Flashcard = Flashcard(deckID: UUID().uuidString)

    private var databaseManager: DatabaseManagerProtocol

    // MARK: - Initializer
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }

    // MARK: - Flashcard Operation Methods
    func fetchFlashcard(id: String) async throws -> Flashcard? {
        return try await databaseManager.fetchFlashcard(id: id)
    }

    func createFlashcard(flashcard: Flashcard) async throws {
        try await databaseManager.createFlashcard(flashcard: flashcard)
    }

    func updateFlashcard(flashcard: Flashcard) async throws {
        try await databaseManager.updateFlashcardWithNewFlashcard(flashcard: flashcard)
    }

    func updateFlashcard(id: String, updates: [FlashcardUpdate]) async throws {
        try await databaseManager.updateFlashcard(updates: updates, for: id)
    }

    func deleteFlashcard(id: String) async throws {
        try await databaseManager.deleteFlashcard(by: id)
    }

    // MARK: - Deck Operation Methods
    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseManager.fetchDeck(for: id)
    }
}
