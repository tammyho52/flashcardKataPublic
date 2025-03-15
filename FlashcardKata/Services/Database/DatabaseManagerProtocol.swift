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
    var userID: String { get }
    var decks: [Deck] { get set }
    var flashcards: [Flashcard] { get set }
    var errorMessage: String? { get set }

    func isGuestUser() -> Bool
    func navigateToSignInWithoutAccount()

    func fetchInitialParentDecks() async throws -> [Deck]
    func fetchMoreParentDecks(lastDeckID: String) async throws -> [Deck]
    func fetchSubdecks(for subdeckIDs: [String]) async throws -> [Deck]
    func fetchAllParentDecks(deckCountLimit: Int?) async throws -> [Deck]
    func fetchAllSubDecks(deckCountLimit: Int?) async throws -> [Deck]
    func fetchDeck(for id: String) async throws -> Deck?
    func fetchDecks(ids: [String]) async throws -> [Deck]
    func fetchSubDecks(for parentDeckID: String) async throws -> [Deck]
    func fetchSearchDecks(for searchText: String) async throws -> [SearchResult]
    func createDeck(deck: Deck) async throws
    func deleteDeck(by id: String) async throws
    func updateDeck(updates: [DeckUpdate], for id: String) async throws
    func updateDeck(newDeck: Deck) async throws
    func isDeckNameAvailable(deckName: String) async throws -> Bool
    func addSubdeckIDs(subdeckIDs: [String], toParentDeckID: String) async throws
    func deleteSubdeckIDs(subdeckIDs: [String], fromParentDeckID: String) async throws
    func deleteDeckAndAssociatedData(id: String) async throws
    func updateDeckUpdatedDate(for id: String) async throws

    func fetchInitialFlashcards(forFlashcardIDs: [String]) async throws -> [Flashcard]
    func fetchMoreFlashcards(lastFlashcardID: String, flashcardIDs: [String]) async throws -> [Flashcard]
    func fetchAllFlashcards(flashcardLimit: Int?) async throws -> [Flashcard]
    func fetchFlashcards(forDeckID: String) async throws -> [Flashcard]
    func fetchFlashcard(id: String) async throws -> Flashcard?
    func fetchFlashcards(ids: [String]) async throws -> [Flashcard]
    func fetchRandomFlashcards() async throws -> [Flashcard]
    func fetchSearchFlashcards(for searchText: String) async throws -> [SearchResult]
    func createFlashcard(flashcard: Flashcard) async throws
    func deleteFlashcard(by id: String) async throws
    func updateFlashcard(updates: [FlashcardUpdate], for id: String) async throws
    func updateFlashcard(flashcard: Flashcard) async throws

    func loadInitialData() async throws
    func hasFlashcards() async throws -> Bool
    func loadParentDecksWithSubDecks() async throws -> [(Deck, [Deck])]
    func loadDecksWithFlashcards(deckIDs: [String]) async throws -> [(Deck, [Flashcard])]

    func hasReviewSessionSummaries() async throws -> Bool
    func fetchAllReviewSessionSummaries() async throws -> [ReviewSessionSummary]
    func fetchReviewSessionSummaries(for date: Date) async throws -> [ReviewSessionSummary]
    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws
    func calculateStreak(startDate: Date) async throws -> Int
    func deleteAllUserData() async throws
}
