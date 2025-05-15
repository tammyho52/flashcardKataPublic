//
//  DatabaseManagerProtocol.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Protocol for Database Manager, defining the required methods for
//  managing decks, flashcards, and review session summaries.

import Foundation

@MainActor
protocol DatabaseManagerProtocol {
    var decks: [Deck] { get set }
    var subdecks: [Deck] { get set }
    var flashcards: [Flashcard] { get set }
    var errorMessage: String? { get set }
    var userID: String { get }
    
    // MARK: - Initial Data Loading
    func loadInitialData() async throws
    
    // MARK: - General
    func isGuestUser() -> Bool
    func navigateToSignInWithoutAccount()
    func hasFlashcards() async -> Bool
    func isDeckNameAvailable(deckName: String) async -> Bool
    func hasReviewSessionSummaries() async -> Bool
    func getAccountCreationDate() async throws -> Date?
    
    // MARK: - Dynamic Data Loading
    func fetchDecksWithFlashcards(deckIDs: [String]) async throws -> [(Deck, [Flashcard])]
    func deleteAllUserData() async throws
    func deleteDeckAndAssociatedData(id: String) async throws
    func loadFlashcardDisplayModels(
        flashcardIDs: Set<String>,
        flashcardLimit: Int?,
        displayCardSort: CardSort
    ) async throws -> [FlashcardDisplayModel]
    
    // MARK: - Deck Fetch Management
    func fetchAllParentDecks(deckCountLimit: Int?) async throws -> [Deck]
    func fetchInitialParentDecks() async throws -> [Deck]
    func fetchMoreParentDecks(lastDeckID: String) async throws -> [Deck]
    func fetchSubdecks(for subdeckIDs: [String]) async throws -> [Deck]
    func fetchAllDecks() async throws -> [Deck]
    func fetchAllSubdecks(deckCountLimit: Int?) async throws -> [Deck]
    func fetchParentDecksWithSubDecks() async throws -> [(Deck, [Deck])]
    func fetchDeck(for id: String) async throws -> Deck?
    func fetchDecks(ids: [String]) async throws -> [Deck]
    func fetchSubDecks(for parentDeckID: String) async throws -> [Deck]
    func fetchSearchDecks(for searchText: String) async throws -> [SearchResult]
    
    // MARK: - Deck CRUD Methods
    func addSubdeckIDs(subdeckIDs: [String], toParentDeckID: String) async throws
    func deleteSubdeckIDs(subdeckIDs: [String], fromParentDeckID: String) async throws
    func updateDeckUpdatedDate(for id: String) async throws
    func createDeck(deck: Deck) async throws
    func deleteDeck(by id: String) async throws
    func updateDeck(updates: [DeckUpdate], for id: String) async throws
    func updateDeckWithNewDeck(newDeck: Deck) async throws
    
    // MARK: - Flashcard Fetch Methods
    func fetchInitialFlashcards(forFlashcardIDs: [String]) async throws -> [Flashcard]
    func fetchMoreFlashcards(lastFlashcardID: String, flashcardIDs: [String]) async throws -> [Flashcard]
    func fetchSearchFlashcards(for searchText: String) async throws -> [SearchResult]
    func fetchAllFlashcards(flashcardLimit: Int?) async throws -> [Flashcard]
    func fetchFlashcardsForDeckID(deckID: String) async throws -> [Flashcard]
    func fetchFlashcard(id: String) async throws -> Flashcard?
    func fetchFlashcards(ids: [String]) async throws -> [Flashcard]
    
    // MARK: - Flashcard CRUD Methods
    func createFlashcard(flashcard: Flashcard) async throws
    func deleteFlashcard(by id: String) async throws
    func updateFlashcard(updates: [FlashcardUpdate], for id: String) async throws
    func updateFlashcardWithNewFlashcard(flashcard: Flashcard) async throws
    
    // MARK: - Review Session Summary Methods
    func fetchAllReviewSessionSummaries() async throws -> [ReviewSessionSummary]
    func fetchReviewSessionSummaries(for date: Date) async -> [ReviewSessionSummary]
    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws
    func calculateStreak(startDate: Date) async -> Int
}
