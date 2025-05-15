//
//  AnyDatabaseManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class wraps any database manager that conforms to the DatabaseManagerProtocol.

import SwiftUI
import Combine

/// A type-erased wrapper for `DatabaseManagerProtocol`. This allows decoupling database managers from the concrete implementation.
@MainActor
final class AnyDatabaseManager: ObservableObject, DatabaseManagerProtocol {
    // MARK: - Properties
    @Published var decks: [Deck] = []
    @Published var subdecks: [Deck] = []
    @Published var flashcards: [Flashcard] = []
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    // These closures are used to forward calls to the wrapped database manager
    private var _userID: () -> String
    private let _loadInitialData: () async throws -> Void
    private let _isGuestUser: () -> Bool
    private let _navigateToSignInWithoutAccount: () -> Void
    private let _getAccountCreationDate: () async throws -> Date?
    private let _hasFlashcards: () async -> Bool
    private let _isDeckNameAvailable: (String) async -> Bool
    private let _hasReviewSessionSummaries: () async -> Bool
    private let _fetchDecksWithFlashcards: ([String]) async throws -> [(Deck, [Flashcard])]
    private let _deleteAllUserData: () async throws -> Void
    private let _deleteDeckAndAssociatedData: (String) async throws -> Void
    private let _loadFlashcardDisplayModels: (Set<String>, Int?, CardSort) async throws -> [FlashcardDisplayModel]
    private let _fetchAllParentDecks: (Int?) async throws -> [Deck]
    private let _fetchInitialParentDecks: () async throws -> [Deck]
    private let _fetchMoreParentDecks: (String) async throws -> [Deck]
    private let _fetchSubdecks: ([String]) async throws -> [Deck]
    private let _fetchAllDecks: () async throws -> [Deck]
    private let _fetchAllSubdecks: (Int?) async throws -> [Deck]
    private let _fetchParentDecksWithSubDecks: () async throws -> [(Deck, [Deck])]
    private let _fetchDeck: (String) async throws -> Deck?
    private let _fetchDecks: ([String]) async throws -> [Deck]
    private let _fetchSubDecks: (String) async throws -> [Deck]
    private let _fetchSearchDecks: (String) async throws -> [SearchResult]
    private let _addSubdeckIDs: ([String], String) async throws -> Void
    private let _deleteSubdeckIDs: ([String], String) async throws -> Void
    private let _updateDeckUpdatedDate: (String) async throws -> Void
    private let _createDeck: (Deck) async throws -> Void
    private let _deleteDeck: (String) async throws -> Void
    private let _updateDeck: ([DeckUpdate], String) async throws -> Void
    private let _updateDeckWithNewDeck: (Deck) async throws -> Void
    private let _fetchInitialFlashcards: ([String]) async throws -> [Flashcard]
    private let _fetchMoreFlashcards: (String, [String]) async throws -> [Flashcard]
    private let _fetchSearchFlashcards: (String) async throws -> [SearchResult]
    private let _fetchAllFlashcards: (Int?) async throws -> [Flashcard]
    private let _fetchFlashcardsForDeckID: (String) async throws -> [Flashcard]
    private let _fetchFlashcard: (String) async throws -> Flashcard?
    private let _fetchFlashcards: ([String]) async throws -> [Flashcard]
    private let _createFlashcard: (Flashcard) async throws -> Void
    private let _deleteFlashcard: (String) async throws -> Void
    private let _updateFlashcard: ([FlashcardUpdate], String) async throws -> Void
    private let _updateFlashcardWithNewFlashcard: (Flashcard) async throws -> Void
    private let _fetchAllReviewSessionSummaries: () async throws -> [ReviewSessionSummary]
    private let _fetchReviewSessionSummaries: (Date) async -> [ReviewSessionSummary]
    private let _createReviewSessionSummary: (ReviewSessionSummary) async throws -> Void
    private let _calculateStreak: (Date) async -> Int
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init<T: DatabaseManagerProtocol & DatabaseManagerPublisherProtocol & ObservableObject>(databaseManager: T) {
        // The closures below forward the calls to the wrapped database manager
        _userID = { databaseManager.userID }
        _loadInitialData = { try await databaseManager.loadInitialData() }
        _isGuestUser = { databaseManager.isGuestUser() }
        _navigateToSignInWithoutAccount = { databaseManager.navigateToSignInWithoutAccount() }
        _getAccountCreationDate = { try await databaseManager.getAccountCreationDate() }
        _hasFlashcards = { await databaseManager.hasFlashcards() }
        _isDeckNameAvailable = { deckName in await databaseManager.isDeckNameAvailable(deckName: deckName) }
        _hasReviewSessionSummaries = { await databaseManager.hasReviewSessionSummaries() }
        _fetchDecksWithFlashcards = { deckIDs in try await databaseManager.fetchDecksWithFlashcards(deckIDs: deckIDs) }
        _deleteAllUserData = { try await databaseManager.deleteAllUserData() }
        _deleteDeckAndAssociatedData = { id in try await databaseManager.deleteDeckAndAssociatedData(id: id) }
        _loadFlashcardDisplayModels = { flashcardIDs, flashcardLimit, displayCardSort in try await databaseManager.loadFlashcardDisplayModels(flashcardIDs: flashcardIDs, flashcardLimit: flashcardLimit, displayCardSort: displayCardSort) }
        _fetchAllParentDecks = { deckCountLimit in try await databaseManager.fetchAllParentDecks(deckCountLimit: deckCountLimit) }
        _fetchInitialParentDecks = { try await databaseManager.fetchInitialParentDecks() }
        _fetchMoreParentDecks = { lastDeckID in try await databaseManager.fetchMoreParentDecks(lastDeckID: lastDeckID) }
        _fetchSubdecks = { deckIDs in try await databaseManager.fetchSubdecks(for: deckIDs) }
        _fetchAllDecks = { try await databaseManager.fetchAllDecks() }
        _fetchAllSubdecks = { deckCountLimit in try await databaseManager.fetchAllSubdecks(deckCountLimit: deckCountLimit) }
        _fetchParentDecksWithSubDecks = { try await databaseManager.fetchParentDecksWithSubDecks() }
        _fetchDeck = { id in try await databaseManager.fetchDeck(for: id) }
        _fetchDecks = { ids in try await databaseManager.fetchDecks(ids: ids) }
        _fetchSubDecks = { id in try await databaseManager.fetchSubDecks(for: id) }
        _fetchSearchDecks = { searchText in try await databaseManager.fetchSearchDecks(for: searchText) }
        _addSubdeckIDs = { subdeckIDs, parentDeckID in try await databaseManager.addSubdeckIDs(subdeckIDs: subdeckIDs, toParentDeckID: parentDeckID) }
        _deleteSubdeckIDs = { subdeckIDs, parentDeckID in try await databaseManager.deleteSubdeckIDs(subdeckIDs: subdeckIDs, fromParentDeckID: parentDeckID) }
        _updateDeckUpdatedDate = { id in try await databaseManager.updateDeckUpdatedDate(for: id) }
        _createDeck = { deck in try await databaseManager.createDeck(deck: deck) }
        _deleteDeck = { id in try await databaseManager.deleteDeck(by: id) }
        _updateDeck = { deckUpdates, id in try await databaseManager.updateDeck(updates: deckUpdates, for: id) }
        _updateDeckWithNewDeck = { deck in try await databaseManager.updateDeckWithNewDeck(newDeck: deck) }
        _fetchInitialFlashcards = { deckIDs in try await databaseManager.fetchInitialFlashcards(forFlashcardIDs: deckIDs) }
        _fetchMoreFlashcards = { lastFlashcardID, flashcardIDs in try await databaseManager.fetchMoreFlashcards(lastFlashcardID: lastFlashcardID, flashcardIDs: flashcardIDs) }
        _fetchSearchFlashcards = { searchText in try await databaseManager.fetchSearchFlashcards(for: searchText) }
        _fetchAllFlashcards = { flashcardLimit in try await databaseManager.fetchAllFlashcards(flashcardLimit: flashcardLimit) }
        _fetchFlashcardsForDeckID = { deckID in try await databaseManager.fetchFlashcardsForDeckID(deckID: deckID) }
        _fetchFlashcard = { id in try await databaseManager.fetchFlashcard(id: id) }
        _fetchFlashcards = { ids in try await databaseManager.fetchFlashcards(ids: ids) }
        _createFlashcard = { flashcard in try await databaseManager.createFlashcard(flashcard: flashcard) }
        _deleteFlashcard = { id in try await databaseManager.deleteFlashcard(by: id) }
        _updateFlashcard = { flashcardUpdates, id in try await databaseManager.updateFlashcard(updates: flashcardUpdates, for: id) }
        _updateFlashcardWithNewFlashcard = { flashcard in try await databaseManager.updateFlashcardWithNewFlashcard(flashcard: flashcard) }
        _fetchAllReviewSessionSummaries = { try await databaseManager.fetchAllReviewSessionSummaries() }
        _fetchReviewSessionSummaries = { date in await databaseManager.fetchReviewSessionSummaries(for: date) }
        _createReviewSessionSummary = { summary in try await databaseManager.createReviewSessionSummary(summary) }
        _calculateStreak = { startDate in await databaseManager.calculateStreak(startDate: startDate) }
        
        // Subscribe to the database manager's publishers
        databaseManager.decksPublisher
            .sink { [weak self] decks in
                self?.decks = decks
            }
            .store(in: &cancellables)
        
        databaseManager.subdecksPublisher
            .sink { [weak self] subdecks in
                self?.subdecks = subdecks
            }
            .store(in: &cancellables)
        
        databaseManager.flashcardsPublisher
            .sink { [weak self] flashcards in
                self?.flashcards = flashcards
            }
            .store(in: &cancellables)
        
        databaseManager.errorMessagePublisher
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Forwarded Properties
    var userID: String {
        _userID()
    }
    
    // MARK: - Forwarded Methods
    func loadInitialData() async throws {
        try await _loadInitialData()
    }
    
    func isGuestUser() -> Bool {
        _isGuestUser()
    }
    
    func navigateToSignInWithoutAccount() {
        _navigateToSignInWithoutAccount()
    }
    
    func getAccountCreationDate() async throws -> Date? {
        try await _getAccountCreationDate()
    }
    
    func hasFlashcards() async -> Bool {
        await _hasFlashcards()
    }
    
    func isDeckNameAvailable(deckName: String) async -> Bool {
        await _isDeckNameAvailable(deckName)
    }
    
    func hasReviewSessionSummaries() async -> Bool {
        await _hasReviewSessionSummaries()
    }
    
    func fetchDecksWithFlashcards(deckIDs: [String]) async throws -> [(Deck, [Flashcard])] {
        try await _fetchDecksWithFlashcards(deckIDs)
    }
    
    func deleteAllUserData() async throws {
        try await _deleteAllUserData()
    }
    
    func deleteDeckAndAssociatedData(id: String) async throws {
        try await _deleteDeckAndAssociatedData(id)
    }
    
    func loadFlashcardDisplayModels(flashcardIDs: Set<String>, flashcardLimit: Int?, displayCardSort: CardSort) async throws -> [FlashcardDisplayModel] {
        try await _loadFlashcardDisplayModels(flashcardIDs, flashcardLimit, displayCardSort)
    }
    
    func fetchAllParentDecks(deckCountLimit: Int?) async throws -> [Deck] {
        try await _fetchAllParentDecks(deckCountLimit)
    }
    
    func fetchInitialParentDecks() async throws -> [Deck] {
        try await _fetchInitialParentDecks()
    }
    
    func fetchMoreParentDecks(lastDeckID: String) async throws -> [Deck] {
        try await _fetchMoreParentDecks(lastDeckID)
    }
    
    func fetchSubdecks(for deckIDs: [String]) async throws -> [Deck] {
        try await _fetchSubdecks(deckIDs)
    }
    
    func fetchAllDecks() async throws -> [Deck] {
        try await _fetchAllDecks()
    }
    
    func fetchAllSubdecks(deckCountLimit: Int?) async throws -> [Deck] {
        try await _fetchAllSubdecks(deckCountLimit)
    }
    
    func fetchParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        try await _fetchParentDecksWithSubDecks()
    }
    
    func fetchDeck(for id: String) async throws -> Deck? {
        try await _fetchDeck(id)
    }
    
    func fetchDecks(ids: [String]) async throws -> [Deck] {
        try await _fetchDecks(ids)
    }
    
    func fetchSubDecks(for parentDeckID: String) async throws -> [Deck] {
        try await _fetchSubDecks(parentDeckID)
    }
    
    func fetchSearchDecks(for searchText: String) async throws -> [SearchResult] {
        try await _fetchSearchDecks(searchText)
    }
    
    func addSubdeckIDs(subdeckIDs: [String], toParentDeckID: String) async throws {
        try await _addSubdeckIDs(subdeckIDs, toParentDeckID)
    }
    
    func deleteSubdeckIDs(subdeckIDs: [String], fromParentDeckID: String) async throws {
        try await _deleteSubdeckIDs(subdeckIDs, fromParentDeckID)
    }
    
    func updateDeckUpdatedDate(for id: String) async throws {
        try await _updateDeckUpdatedDate(id)
    }
    
    func createDeck(deck: Deck) async throws {
        try await _createDeck(deck)
    }
    
    func deleteDeck(by id: String) async throws {
        try await _deleteDeck(id)
    }
    
    func updateDeck(updates: [DeckUpdate], for id: String) async throws {
        try await _updateDeck(updates, id)
    }
    
    func updateDeckWithNewDeck(newDeck: Deck) async throws {
        try await _updateDeckWithNewDeck(newDeck)
    }
    
    func fetchInitialFlashcards(forFlashcardIDs deckIDs: [String]) async throws -> [Flashcard] {
        try await _fetchInitialFlashcards(deckIDs)
    }
    
    func fetchMoreFlashcards(lastFlashcardID: String, flashcardIDs: [String]) async throws -> [Flashcard] {
        try await _fetchMoreFlashcards(lastFlashcardID, flashcardIDs)
    }
    
    func fetchSearchFlashcards(for searchText: String) async throws -> [SearchResult] {
        try await _fetchSearchFlashcards(searchText)
    }
    
    func fetchAllFlashcards(flashcardLimit: Int?) async throws -> [Flashcard] {
        try await _fetchAllFlashcards(flashcardLimit)
    }
    
    func fetchFlashcardsForDeckID(deckID: String) async throws -> [Flashcard] {
        try await _fetchFlashcardsForDeckID(deckID)
    }
    
    func fetchFlashcard(id: String) async throws -> Flashcard? {
        try await _fetchFlashcard(id)
    }
    
    func fetchFlashcards(ids: [String]) async throws -> [Flashcard] {
        try await _fetchFlashcards(ids)
    }
    
    func createFlashcard(flashcard: Flashcard) async throws {
        try await _createFlashcard(flashcard)
    }
    
    func deleteFlashcard(by id: String) async throws {
        try await _deleteFlashcard(id)
    }
    
    func updateFlashcard(updates: [FlashcardUpdate], for id: String) async throws {
        try await _updateFlashcard(updates, id)
    }
    
    func updateFlashcardWithNewFlashcard(flashcard: Flashcard) async throws {
        try await _updateFlashcardWithNewFlashcard(flashcard)
    }
    
    func fetchAllReviewSessionSummaries() async throws -> [ReviewSessionSummary] {
        try await _fetchAllReviewSessionSummaries()
    }
    
    func fetchReviewSessionSummaries(for date: Date) async -> [ReviewSessionSummary] {
        await _fetchReviewSessionSummaries(date)
    }
    
    func createReviewSessionSummary(_ summary: ReviewSessionSummary) async throws {
        try await _createReviewSessionSummary(summary)
    }
    
    func calculateStreak(startDate: Date) async -> Int {
        await _calculateStreak(startDate)
    }
}
