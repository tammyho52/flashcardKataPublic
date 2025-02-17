//
//  FlashcardFormViewModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation

@MainActor
final class FlashcardFormViewModel: ObservableObject {
    @Published var initialFlashcard: Flashcard = Flashcard(deckID: UUID().uuidString)
    
    private var databaseManager: DatabaseManagerProtocol
    
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }
    
    func fetchFlashcard(id: String) async throws -> Flashcard? {
        return try await databaseManager.fetchFlashcard(id: id)
    }
    
    func createFlashcard(flashcard: Flashcard) async throws {
        try await databaseManager.createFlashcard(flashcard: flashcard)
    }
    
    func updateFlashcard(flashcard: Flashcard) async throws {
        try await databaseManager.updateFlashcard(flashcard: flashcard)
    }
    
    func updateFlashcard(id: String, updates: [FlashcardUpdate]) async throws {
        try await databaseManager.updateFlashcard(updates: updates, for: id)
    }
    
    func deleteFlashcard(id: String) async throws {
        try await databaseManager.deleteFlashcard(by: id)
    }
    
    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseManager.fetchDeck(for: id)
    }
}
