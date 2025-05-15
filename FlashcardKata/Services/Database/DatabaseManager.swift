//
//  DatabaseManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class manages the app's data flow and interactions with the backend,
//  including fetching, updating, and deleting decks, flashcards, and review session summaries.

import SwiftUI

/// A manager for handling the app's data flow and backend interactions.
@MainActor
final class DatabaseManager: ObservableObject, DatabaseManagerProtocol, DatabaseManagerPublisherProtocol {
    // MARK: - Properties
    @AppStorage(UserDefaultsKeys.authenticationProvider) private var authenticationProvider: AuthenticationProvider?
    @Published var decks: [Deck] = []
    @Published var subdecks: [Deck] = []
    @Published var flashcards: [Flashcard] = []
    @Published var errorMessage: String?
    
    // Published properties for Combine publishers.
    var decksPublisher: Published<[Deck]>.Publisher {
        $decks
    }
    var subdecksPublisher: Published<[Deck]>.Publisher {
        $subdecks
    }
    var flashcardsPublisher: Published<[Flashcard]>.Publisher {
        $flashcards
    }
    var errorMessagePublisher: Published<String?>.Publisher {
        $errorMessage
    }

    // Services and dependencies for managing data.
    private let deckService: DeckService
    private let flashcardService: FlashcardService
    private let reviewSessionSummaryService: ReviewSessionSummaryService
    private let authenticationManager: AnyAuthenticationManager
    
    // Cache Managers for storing data temporarily.
    private let deckCache = CacheManager<Deck>()
    private let subdeckCache = CacheManager<Deck>()
    private let flashcardCache = CacheManager<Flashcard>()
    private let memoryManager: MemoryManager = MemoryManager(clearAllCachesAction: {})
    
    private let fetchItemLimit = ContentConstants.fetchItemLimit
    var userID: String {
        authenticationManager.userID ?? ""
    }
    
    // MARK: - Initialization
    init(
        deckService: DeckService,
        flashcardService: FlashcardService,
        reviewSessionSummaryService: ReviewSessionSummaryService,
        authenticationManager: AnyAuthenticationManager
    ) {
        self.deckService = deckService
        self.flashcardService = flashcardService
        self.reviewSessionSummaryService = reviewSessionSummaryService
        self.authenticationManager = authenticationManager
    }

    // MARK: - Initial Data Loading
    /// Loads the initial data for decks, subdecks, and flashcards into the cache.
    func loadInitialData() async throws {
        // Clear all caches when the app starts.
        memoryManager.clearAllCachesAction = { [weak self] in
            guard let self else { return }
            await self.deckCache.clearCache()
            await self.subdeckCache.clearCache()
            await self.flashcardCache.clearCache()
        }
        
        // Load initial data into caches.
        async let deckTask: () = try await loadDeckDataToCache()
        async let subdeckTask: () = try await loadSubdeckDataToCache()
        async let flashcardTask: () = try await loadFlashcardDataToCache()
        
        // Wait for all tasks to complete.
        try await deckTask
        try await subdeckTask
        try await flashcardTask
    }

    private func loadDeckDataToCache() async throws {
        let decks = try await fetchAllParentDecks(deckCountLimit: deckCache.cacheLimit)
        await deckCache.storeInitialData(items: decks)
    }

    private func loadSubdeckDataToCache() async throws {
        let subdecks = try await fetchAllSubdecks(deckCountLimit: subdeckCache.cacheLimit)
        await subdeckCache.storeInitialData(items: subdecks)
    }

    private func loadFlashcardDataToCache() async throws {
        let flashcards = try await fetchAllFlashcards(flashcardLimit: flashcardCache.cacheLimit)
        await flashcardCache.storeInitialData(items: flashcards)
    }
    
    // MARK: - General Methods
    func isGuestUser() -> Bool {
        authenticationProvider == .guest
    }

    func navigateToSignInWithoutAccount() {
        authenticationManager.navigateToSignInWithoutAccount()
    }
    
    func hasFlashcards() async -> Bool {
        return await flashcardService.hasFlashcards(userID: userID)
    }
    
    func isDeckNameAvailable(deckName: String) async -> Bool {
        return await deckService.isDeckNameAvailable(deckName: deckName, userID: userID)
    }

    func hasReviewSessionSummaries() async -> Bool {
        return await reviewSessionSummaryService.hasReviewSessionSummaries(userID: userID)
    }
    
    func getAccountCreationDate() async throws -> Date? {
        return try await authenticationManager.getAccountCreationDate()
    }

    // MARK: - Dynamic Data Loading
    /// Fetches decks along with their flashcards based on the provided deck IDs.
    func fetchDecksWithFlashcards(deckIDs: [String]) async throws -> [(Deck, [Flashcard])] {
        let decks = try await fetchDecks(ids: deckIDs)
        var results: [(Deck, [Flashcard])] = []
        
        // Fetch flashcards for each deck
        for deck in decks {
            let flashcards = try await fetchFlashcardsForDeckID(deckID: deck.id)
            guard !flashcards.isEmpty else { continue }
            results.append((deck, flashcards))
        }
        return results
    }
    
    /// Deletes all user data including decks, flashcards, and review session summaries.
    func deleteAllUserData() async throws {
        // Delete all review session summaries
        try await reviewSessionSummaryService.deleteAllReviewSummaries(userID: userID)
        
        // Delete all decks and their associated data
        let parentDecks = try await fetchAllParentDecks()
        for deck in parentDecks {
            try await deleteDeckAndAssociatedData(id: deck.id)
        }
    }
    
    /// Deletes a deck and its associated data including subdecks and flashcards.
    func deleteDeckAndAssociatedData(id: String) async throws {
        guard let deck = try await fetchDeck(for: id) else {
            reportError(NSError(domain: "Deck not found in deleteDeckAndAssociatedData", code: 0, userInfo: nil))
            return
        }
        
        // If this is a parent deck, delete all subdecks and their flashcards
        if deck.parentDeckID == nil {
            for subdeckID in deck.subdeckIDs {
                // Fetch the subdeck and delete its flashcards
                if let subdeck = try await fetchDeck(for: subdeckID), !subdeck.flashcardIDs.isEmpty {
                    try await deleteBatchFlashcards(ids: subdeck.flashcardIDs)
                }
                // Delete the subdeck
                try await deleteDeck(by: subdeckID)
            }
        } else if let subdeck = try await fetchDeck(for: id),
                  let parentDeckID = subdeck.parentDeckID {
            // If this is a subdeck, remove its reference from the parent deck
            try await deleteSubdeckIDs(subdeckIDs: [id], fromParentDeckID: parentDeckID)
        }
        
        // Delete flashcards in the deck
        if !deck.flashcardIDs.isEmpty {
            try await deleteBatchFlashcards(ids: deck.flashcardIDs)
        }
        
        // Delete the deck itself
        try await deleteDeck(by: id)
        
        // Clear caches
        if deck.parentDeckID != nil {
            await deckCache.deleteItems(ids: [id])
            await subdeckCache.clearCache()
        } else {
            await subdeckCache.deleteItems(ids: [id])
        }
    }
    
    /// Fetches flashcard display models based on the provided flashcard IDs and sort option.
    func loadFlashcardDisplayModels(
        flashcardIDs: Set<String>,
        flashcardLimit: Int? = nil,
        displayCardSort: CardSort
    ) async throws -> [FlashcardDisplayModel] {
        var flashcards: [Flashcard] = []
        var flashcardIDs = flashcardIDs
        
        if flashcardIDs.isEmpty {
            // Fetch all flashcards if no flashcards are selected
            if let fetchedFlashcards = try? await fetchAllFlashcards(flashcardLimit: nil) {
                flashcards = fetchedFlashcards
                flashcardIDs = Set(flashcards.map(\.id))
            }
        } else {
            // Fetch flashcards based on selected IDs
            if let fetchedFlashcards = try? await fetchFlashcards(ids: Array(flashcardIDs)) {
                flashcards = fetchedFlashcards
            }
        }
        
        // Create flashcard display models using the fetched flashcards and their associated decks
        var flashcardDisplayModels: [FlashcardDisplayModel] = []
        for flashcard in flashcards {
            if let flashcardDisplayModel = await createFlashcardDisplayModel(flashcard: flashcard) {
                flashcardDisplayModels.append(flashcardDisplayModel)
            }
        }
        
        // Sort the flashcard display models based on the selected sort option
        return sortFlashcardDisplayModels(displayCardSort: displayCardSort, flashcardDisplayModels: flashcardDisplayModels)
    }
    
    /// Creates a flashcard display model based on the provided flashcard.
    private func createFlashcardDisplayModel(flashcard: Flashcard) async -> FlashcardDisplayModel? {
        // Fetch the deck for the flashcard
        guard let deck = try? await fetchDeck(for: flashcard.deckID) else {
            reportError(NSError(domain: "DeckNotFound", code: 0, userInfo: [NSLocalizedDescriptionKey: "Deck not found for flashcard ID: \(flashcard.deckID)"]))
            return nil
        }
        return FlashcardDisplayModel(flashcard: flashcard, deckNameLabel: deck.deckNameLabel)
    }
}

// MARK: - Deck Fetch Management
extension DatabaseManager {
    /// Fetches all parent decks with a specified count limit.
    func fetchAllParentDecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return try await deckService.fetchAllParentDecks(deckCountLimit: deckCountLimit, userID: userID)
    }

    /// Fetches parent decks with subdecks, up to a specified count limit.
    func fetchInitialParentDecks() async throws -> [Deck] {
        // Check if there are updated decks since the last updated date
        let newDecks = try await deckService.fetchUpdatedParentDecks(userID: userID, lastUpdatedDate: deckCache.lastUpdatedDate)
        await deckCache.storeNewItems(newItems: newDecks)
        
        // Check if there are enough cached decks
        let cacheDecks = await deckCache.retrieveItems()
        if cacheDecks.count >= fetchItemLimit {
            return cacheDecks
        } else if let lastDeck = cacheDecks.last {
            // Fetch more decks if the cache is not full
            let fetchedDecks = try await deckService.fetchMoreParentDecks(userID: userID, lastDeckID: lastDeck.id)
            await deckCache.storeOldItems(oldItems: fetchedDecks)
            return cacheDecks + fetchedDecks
        } else {
            return []
        }
    }

    /// Fetches more parent decks based on the last deck ID.
    func fetchMoreParentDecks(lastDeckID: String) async throws -> [Deck] {
        let fetchedDecks = try await deckService.fetchMoreParentDecks(userID: userID, lastDeckID: lastDeckID)
        await deckCache.storeOldItems(oldItems: fetchedDecks)
        return fetchedDecks
    }
    
    /// Fetches subdecks based on the provided subdeck IDs.
    func fetchSubdecks(for subdeckIDs: [String]) async throws -> [Deck] {
        var cachedSubdecks: [Deck] = []
        var fetchedSubdeckIDs: [String] = []
        
        // Separate cached subdecks from those that need to be fetched
        for subdeckID in subdeckIDs {
            if let subdeck = await subdeckCache.retrieveItem(id: subdeckID) {
                cachedSubdecks.append(subdeck)
            } else {
                fetchedSubdeckIDs.append(subdeckID)
            }
        }
        
        // Fetch missing subdecks from the service
        let fetchedSubdecks = try await deckService.fetchSubdecks(ids: fetchedSubdeckIDs)
        await subdeckCache.storeNewItems(newItems: fetchedSubdecks)
        
        // Combine cached and fetched subdecks, preserving the original ID order
        let allSubdecks = cachedSubdecks + fetchedSubdecks
        let sortedSubdecks = subdeckIDs.compactMap { id in
            allSubdecks.first(where: { $0.id == id })
        }
        return sortedSubdecks
    }
    
    func fetchAllDecks() async throws -> [Deck] {
        return try await deckService.fetchAllDecks(userID: userID)
    }

    func fetchAllSubdecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return try await deckService.fetchAllSubdecks(userID: userID, deckCountLimit: deckCountLimit)
    }

    func fetchParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        return try await deckService.fetchParentDecksWithSubDecks(userID: userID)
    }

    func fetchDeck(for id: String) async throws -> Deck? {
        return try await deckService.fetchDeck(id: id)
    }

    func fetchDecks(ids: [String]) async throws -> [Deck] {
        return try await deckService.fetchDecks(ids: ids)
    }

    func fetchSubDecks(for parentDeckID: String) async throws -> [Deck] {
        return try await deckService.fetchSubDecks(userID: userID, for: parentDeckID)
    }

    func fetchSearchDecks(for searchText: String) async throws -> [SearchResult] {
        return try await deckService.fetchSearchDecks(for: searchText, userID: userID)
    }
}

// MARK: - Deck CRUD Methods
extension DatabaseManager {
    /// Adds subdeck IDs to a parent deck.
    func addSubdeckIDs(subdeckIDs: [String], toParentDeckID: String) async throws {
        let parentDeckUpdates = [DeckUpdate.subdeckIDs(IDUpdate(addIDs: subdeckIDs))]
        try await updateDeck(updates: parentDeckUpdates, for: toParentDeckID)
    }
    
    /// Deletes subdeck IDs from a parent deck.
    func deleteSubdeckIDs(subdeckIDs: [String], fromParentDeckID: String) async throws {
        let parentDeckUpdates = [DeckUpdate.subdeckIDs(IDUpdate(removeIDs: subdeckIDs))]
        try await updateDeck(updates: parentDeckUpdates, for: fromParentDeckID)
        
        await subdeckCache.deleteItems(ids: subdeckIDs)
    }
    
    /// Updates the last updated date for a deck.
    func updateDeckUpdatedDate(for id: String) async throws {
        let deckUpdates: [DeckUpdate] = [.updatedDate(Date())]
        try await deckService.updateDeck(id: id, deckUpdates: deckUpdates)
    }
    
    func createDeck(deck: Deck) async throws {
        var updatedDeck = deck
        updatedDeck.userID = userID
        try await deckService.createDeck(deck: updatedDeck)
    }
    
    func deleteDeck(by id: String) async throws {
        try await deckService.deleteDeck(id: id)
        await deckCache.deleteItems(ids: [id])
        await subdeckCache.deleteItems(ids: [id])
    }
    
    /// Updates a deck with the provided updates.
    func updateDeck(updates: [DeckUpdate], for id: String) async throws {
        try await deckService.updateDeck(id: id, deckUpdates: updates)
        try await updateDeckUpdatedDate(for: id)
        await deckCache.deleteItems(ids: [id])
    }

    /// Updates a deck with a new deck object.
    func updateDeckWithNewDeck(newDeck: Deck) async throws {
        try await deckService.updateDeck(deck: newDeck)
        try await updateDeckUpdatedDate(for: newDeck.id)
        await deckCache.deleteItems(ids: [newDeck.id])
    }
    
    /// Deletes a batch of flashcards by their IDs.
    private func deleteBatchFlashcards(ids: [String]) async throws {
        guard !ids.isEmpty else { return }
        for flashcardID in ids {
            try await deleteFlashcard(by: flashcardID)
        }
    }
}

// MARK: - Flashcard Fetch Methods
extension DatabaseManager {
    /// Fetches initial flashcards based on the provided flashcard IDs and stores in cache.
    func fetchInitialFlashcards(forFlashcardIDs: [String]) async throws -> [Flashcard] {
        // Limit the number of flashcard IDs to fetch to the fetchItemLimit
        let limitedFlashcardIDs = Array(forFlashcardIDs[0..<min(fetchItemLimit, forFlashcardIDs.count)])
        var cachedFlashcards: [Flashcard] = []
        var flashcardIDsToFetch: [String] = []
        
        // Separate cached flashcards from those that need to be fetched
        for flashcardID in limitedFlashcardIDs {
            if let flashcard = await flashcardCache.retrieveItem(id: flashcardID) {
                cachedFlashcards.append(flashcard)
            } else {
                flashcardIDsToFetch.append(flashcardID)
            }
        }
        
        // Fetch missing flashcards from the service
        let fetchedFlashcards = try await flashcardService.fetchFlashcards(ids: flashcardIDsToFetch)
        
        // Cache the newly fetched flashcards
        await flashcardCache.storeNewItems(newItems: fetchedFlashcards)
        
        // Merge cached and fetched flashcards, preserving the original ID order
        let allFlashcards = cachedFlashcards + fetchedFlashcards
        let sortedFlashcards = limitedFlashcardIDs.compactMap { id in
            allFlashcards.first(where: { $0.id == id })
        }
        
        return sortedFlashcards
    }

    /// Fetches more flashcards based on the last flashcard ID and the provided flashcard IDs.
    func fetchMoreFlashcards(lastFlashcardID: String, flashcardIDs: [String]) async throws -> [Flashcard] {
        guard let lastIndex = flashcardIDs.firstIndex(of: lastFlashcardID) else {
            return []
        }
        
        // Limit the number of flashcard IDs to fetch to the fetchItemLimit
        let startIndex = lastIndex + 1
        let limitedFlashcardIDs = Array(flashcardIDs[startIndex..<min(startIndex + fetchItemLimit, flashcardIDs.count)])

        var cachedFlashcards: [Flashcard] = []
        var fetchedFlashcardIDs: [String] = []
        
        // Separate cached flashcards from those that need to be fetched
        for flashcardID in limitedFlashcardIDs {
            if let flashcard = await flashcardCache.retrieveItem(id: flashcardID) {
                cachedFlashcards.append(flashcard)
            } else {
                fetchedFlashcardIDs.append(flashcardID)
            }
        }
        
        // Fetch missing flashcards from the service
        let fetchedFlashcards = try await flashcardService.fetchFlashcards(ids: fetchedFlashcardIDs)
        await flashcardCache.storeOldItems(oldItems: fetchedFlashcards)
        
        // Merge cached and fetched flashcards, preserving the original ID order
        let allFlashcards = cachedFlashcards + fetchedFlashcards
        return flashcardIDs.compactMap { id in
            allFlashcards.first(where: { $0.id == id })
        }
    }
    
    /// Fetches flashcards based on the provided search text and user ID.
    func fetchSearchFlashcards(for searchText: String) async throws -> [SearchResult] {
        let flashcards = try await flashcardService.fetchSearchFlashcards(for: searchText, userID: userID)
        
        // Group flashcards by deckID to fetch deck names and themes
        let groupedFlashcards = Dictionary(grouping: flashcards, by: { $0.deckID })
        let deckIDs = Array(groupedFlashcards.keys)
        let decks = try await deckService.fetchDecks(ids: deckIDs)
        
        // Create search results by combining flashcards with their corresponding deck names and themes
        var searchResults: [SearchResult] = []
        for (deckID, flashcards) in groupedFlashcards {
            if let deck = decks.first(where: { $0.id == deckID }) {
                for flashcard in flashcards {
                    searchResults.append(SearchResult(flashcard: flashcard, deckName: deck.name, theme: deck.theme))
                }
            }
        }
        
        return searchResults
    }

    func fetchAllFlashcards(flashcardLimit: Int? = nil) async throws -> [Flashcard] {
        return try await flashcardService.fetchAllFlashcards(userID: userID, documentLimit: flashcardLimit)
    }

    func fetchFlashcardsForDeckID(deckID: String) async throws -> [Flashcard] {
        return try await flashcardService.fetchFlashcards(userID: userID, for: deckID)
    }

    func fetchFlashcard(id: String) async throws -> Flashcard? {
        return try await flashcardService.fetchFlashcard(id: id)
    }

    func fetchFlashcards(ids: [String]) async throws -> [Flashcard] {
        return try await flashcardService.fetchFlashcards(ids: ids)
    }
}

// MARK: - Flashcard CRUD Methods
extension DatabaseManager {
    func createFlashcard(flashcard: Flashcard) async throws {
        var updatedFlashcard = flashcard
        
        // Assign the user ID to the flashcard before creating it
        updatedFlashcard.userID = userID
        try await flashcardService.createFlashcard(flashcard: updatedFlashcard)
        
        // Update the deck with the new flashcard ID
        let deckUpdate = [DeckUpdate.flashcardIDs(IDUpdate(addIDs: [flashcard.id]))]
        try await updateDeck(updates: deckUpdate, for: flashcard.deckID)
    }
    
    /// Deletes a flashcard by its ID and removes it from the associated deck.
    func deleteFlashcard(by id: String) async throws {
        guard let flashcard = try await flashcardService.fetchFlashcard(id: id) else {
            reportError(NSError(domain: "Flashcard not found in deleteFlashcard", code: 0, userInfo: nil))
            throw AppError.systemError
        }
        
        // Remove the flashcard ID from the deck
        let deckUpdate = [
            DeckUpdate.flashcardIDs(IDUpdate(removeIDs: [id])),
            DeckUpdate.reviewedFlashcardIDs(IDUpdate(removeIDs: [id]))
        ]
        try await updateDeck(updates: deckUpdate, for: flashcard.deckID)
        
        // Delete the flashcard and clear from cache
        try await flashcardService.deleteFlashcard(id: id)
        await flashcardCache.deleteItems(ids: [id])
    }
    
    /// Updates a flashcard with the provided updates.
    func updateFlashcard(updates: [FlashcardUpdate], for id: String) async throws {
        try await flashcardService.updateFlashcard(id: id, flashcardUpdates: updates)
        try await flashcardService.updateFlashcardUpdatedDate(id: id)
        await flashcardCache.deleteItems(ids: [id])
    }
    
    /// Updates a flashcard with a new flashcard object.
    func updateFlashcardWithNewFlashcard(flashcard: Flashcard) async throws {
        try await flashcardService.updateFlashcard(flashcard: flashcard)
        try await flashcardService.updateFlashcardUpdatedDate(id: flashcard.id)
        await flashcardCache.deleteItems(ids: [flashcard.id])
    }
}

// MARK: - Review Session Summary Methods
extension DatabaseManager {
    /// Fetches all review session summaries for the user.
    func fetchAllReviewSessionSummaries() async throws -> [ReviewSessionSummary] {
        return try await reviewSessionSummaryService.fetchAllReviewSessionSummaries(userID: userID)
    }
    
    /// Fetches review session summaries for a specific date.
    func fetchReviewSessionSummaries(for date: Date) async -> [ReviewSessionSummary] {
        return await reviewSessionSummaryService.fetchReviewSessionSummaries(for: date, userID: userID)
    }
    
    /// Creates a new review session summary.
    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws {
        var updatedReviewSessionSummary = reviewSessionSummary
        updatedReviewSessionSummary.userID = userID
        return try await reviewSessionSummaryService.createReviewSessionSummary(updatedReviewSessionSummary)
    }
    
    /// Calculates the streak count for a given date.
    func calculateStreak(startDate: Date) async -> Int {
        return await reviewSessionSummaryService.calculateStreak(startDate: startDate, userID: userID)
    }
}
