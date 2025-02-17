//
//  DeckRepository.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DatabaseManager: ObservableObject, DatabaseManagerProtocol {
    @AppStorage(UserDefaultsKeys.authenticationProvider) private var authenticationProvider: AuthenticationProvider?
    @Published var decks: [Deck] = []
    @Published var subdecks: [Deck] = []
    @Published var flashcards: [Flashcard] = []
    @Published var errorMessage: String?
    
    let deckCache = CacheManager<Deck>()
    let subdeckCache = CacheManager<Deck>()
    let flashcardCache = CacheManager<Flashcard>()
    let memoryManager: MemoryManager = MemoryManager(clearAllCachesAction: {})
    
    let deckService: DeckService
    let flashcardService: FlashcardService
    let reviewSessionSummaryService: ReviewSessionSummaryService
    let authenticationManager: AuthenticationManager
    
    let initialFetchItemLimit = 10
    
    init(deckService: DeckService, flashcardService: FlashcardService, reviewSessionSummaryService: ReviewSessionSummaryService, authenticationManager: AuthenticationManager) {
        self.deckService = deckService
        self.flashcardService = flashcardService
        self.reviewSessionSummaryService = reviewSessionSummaryService
        self.authenticationManager = authenticationManager
    }
    
    var userID: String {
        authenticationManager.userID
    }
    
    // MARK: - General Methods
    
    func isGuestUser() -> Bool {
        authenticationProvider == .guest
    }
    
    func navigateToSignInWithoutAccount() {
        authenticationManager.navigateToSignInWithoutAccount()
    }
    
    func loadInitialData() async throws {
        do {
            try await self.loadDeckDataToCache()
            try await self.loadSubdeckDataToCache()
            try await self.loadFlashcardDataToCache()
            
            memoryManager.clearAllCachesAction = { [weak self] in
                guard let self else { return }
                await self.deckCache.clearCache()
                await self.subdeckCache.clearCache()
                await self.flashcardCache.clearCache()
            }
        } catch is DataManagerError {
            self.errorMessage = "We had trouble connecting to the server. Please try again later."
        } catch {
            self.errorMessage = "Something went wrong. We're working to fix this as quickly as possible."
        }
    }
    
    // MARK: - Cache Methods
    private func loadDeckDataToCache() async throws {
        let decks = try await fetchAllParentDecks(deckCountLimit: deckCache.cacheLimit)
        await deckCache.storeInitialData(items: decks)
    }
    
    private func loadSubdeckDataToCache() async throws {
        let subdecks = try await fetchAllSubDecks(deckCountLimit: subdeckCache.cacheLimit)
        await subdeckCache.storeInitialData(items: subdecks)
    }
    
    private func loadFlashcardDataToCache() async throws {
        let flashcards = try await fetchAllFlashcards(flashcardLimit: flashcardCache.cacheLimit)
        await flashcardCache.storeInitialData(items: flashcards)
    }
    
    // MARK: - General Methods
    func hasFlashcards() async throws -> Bool {
        do {
            return try await flashcardService.hasFlashcards(userID: userID)
        } catch {
            return false
        }
    }
    
    func hasReviewSessionSummaries() async throws -> Bool {
        do {
            return try await reviewSessionSummaryService.hasReviewSessionSummaries(userID: userID)
        } catch {
            return false
        }
    }
    
    //MARK: - Deck Fetch Methods
    func fetchAllParentDecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        do {
            let predicates: [QueryPredicate] = [
                .isNull(field: "parentDeckID")
            ]
            return try await deckService.query(predicates: predicates, userID: userID, deckCountLimit: deckCountLimit)
        } catch {
            throw DataManagerError.deckFetchError(error: error)
        }
    }
    
    func fetchInitialParentDecks() async throws -> [Deck] {
        let predicates: [QueryPredicate] = [
            .isNull(field: "parentDeckID"),
            .isGreaterThan(field: "updatedDate", value: deckCache.lastUpdatedDate)
        ]
        let newDecks = try await deckService.query(predicates: predicates, userID: userID)
        await deckCache.storeNewItems(newItems: newDecks)
        
        let cacheDecks = await deckCache.retrieveItems()
        if cacheDecks.count >= initialFetchItemLimit {
            return cacheDecks
        } else if let lastDeck = cacheDecks.last {
            let lastDocumentSnapshot = try await deckService.getLastDocumentSnapshot(id: lastDeck.id)
            let fetchedDecks = try await deckService.queryPaginatedDecks(predicates: [.isNull(field: "parentDeckID")], userID: userID, lastDocument: lastDocumentSnapshot)
            await deckCache.storeOldItems(oldItems: fetchedDecks)
            return cacheDecks + fetchedDecks
        } else {
            return []
        }
    }
    
    func fetchMoreParentDecks(lastDeckID: String) async throws -> [Deck] {
        let lastDocumentSnapshot = try await deckService.getLastDocumentSnapshot(id: lastDeckID)
        let fetchedDecks = try await deckService.queryPaginatedDecks(predicates: [.isNull(field: "parentDeckID")], userID: userID, lastDocument: lastDocumentSnapshot)
        await deckCache.storeOldItems(oldItems: fetchedDecks)
        return fetchedDecks
    }
    
    func fetchInitialFlashcards(forFlashcardIDs: [String]) async throws -> [Flashcard] {
        let limitedFlashcardIDs = Array(forFlashcardIDs[0 ..< min(initialFetchItemLimit, forFlashcardIDs.count)])
        
        var cachedFlashcards: [Flashcard] = []
        var fetchedFlashcardIDs: [String] = []
        var fetchedFlashcards: [Flashcard] = []
        
        for flashcardID in limitedFlashcardIDs {
            if let flashcard = await flashcardCache.retrieveItem(id: flashcardID) {
                cachedFlashcards.append(flashcard)
            } else {
                fetchedFlashcardIDs.append(flashcardID)
            }
        }
        
        let flashcards = try await flashcardService.fetchFlashcards(ids: fetchedFlashcardIDs)
        fetchedFlashcards.append(contentsOf: flashcards)
        
        await flashcardCache.storeNewItems(newItems: fetchedFlashcards)
        let allFlashcards = cachedFlashcards + fetchedFlashcards
        let sortedFlashcards = forFlashcardIDs.compactMap { id in
            allFlashcards.first(where: { $0.id == id })
        }
        return sortedFlashcards
    }
    
    func fetchMoreFlashcards(lastFlashcardID: String, forFlashcardIDs: [String]) async throws -> [Flashcard] {
        if let lastIndex = forFlashcardIDs.firstIndex(of: lastFlashcardID) {
            let limitedFlashcardIDs = Array(forFlashcardIDs[lastIndex + 1 ..< min(lastIndex + 11, forFlashcardIDs.count)])
            
            var cachedFlashcards: [Flashcard] = []
            var fetchedFlashcardIDs: [String] = []
            
            for flashcardID in limitedFlashcardIDs {
                if let flashcard = await flashcardCache.retrieveItem(id: flashcardID) {
                    cachedFlashcards.append(flashcard)
                } else {
                    fetchedFlashcardIDs.append(flashcardID)
                }
            }
            
            var fetchedFlashcards: [Flashcard] = []
            let flashcards = try await flashcardService.fetchFlashcards(ids: fetchedFlashcardIDs)
            fetchedFlashcards.append(contentsOf: flashcards)
            await flashcardCache.storeOldItems(oldItems: fetchedFlashcards)
            let allFlashcards = cachedFlashcards + fetchedFlashcards
            return forFlashcardIDs.compactMap { id in
                allFlashcards.first(where: { $0.id == id })
            }
        }
        return []
    }
    
    func fetchSubdecks(for subdeckIDs: [String]) async throws -> [Deck] {
        var cachedSubdecks: [Deck] = []
        var fetchedSubdeckIDs: [String] = []
        var fetchedSubdecks: [Deck] = []
        
        for subdeckID in subdeckIDs {
            if let subdeck = await subdeckCache.retrieveItem(id: subdeckID) {
                cachedSubdecks.append(subdeck)
            } else {
                fetchedSubdeckIDs.append(subdeckID)
            }
        }
        
        let batchSize = 10
        let batches = stride(from: 0, to: fetchedSubdeckIDs.count, by: batchSize).map {
            Array(fetchedSubdeckIDs[$0 ..< min($0 + batchSize, fetchedSubdeckIDs.count)])
        }
        
        for batch in batches {
            let subdecks = try await deckService.fetchDecks(ids: batch)
            fetchedSubdecks.append(contentsOf: subdecks)
        }
        await subdeckCache.storeNewItems(newItems: fetchedSubdecks)
        let allSubdecks = cachedSubdecks + fetchedSubdecks
        let sortedSubdecks = subdeckIDs.compactMap { id in
            allSubdecks.first(where: { $0.id == id })
        }
        return sortedSubdecks
    }
    
    func fetchAllSubDecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        do {
            let predicates: [QueryPredicate] = [
                .isNotNull(field: "parentDeckID")
            ]
            return try await deckService.query(predicates: predicates, userID: userID, deckCountLimit: deckCountLimit)
        } catch {
            throw DataManagerError.deckFetchError(error: error)
        }
    }
    
    func fetchDeck(for id: String) async throws -> Deck? {
        do {
            return try await deckService.fetchDeck(id: id)
        } catch {
            throw DataManagerError.deckFetchError(error: error)
        }
    }
    
    func fetchDecks(ids: [String]) async throws -> [Deck] {
        do {
            return try await deckService.fetchDecks(ids: ids)
        } catch {
            throw DataManagerError.deckFetchError(error: error)
        }
    }
    
    func fetchSubDecks(for parentDeckID: String) async throws -> [Deck] {
        do {
            let predicates: [QueryPredicate] = [
                .isEqualTo(field: "parentDeckID", value: parentDeckID)
            ]
            return try await deckService.query(predicates: predicates, userID: userID)
        } catch {
            
            throw DataManagerError.deckFetchError(error: error)
        }
    }
    
    func fetchAllDecks() async throws -> [Deck] {
        let predicates: [QueryPredicate] = []
        return try await deckService.query(predicates: predicates, userID: userID)
    }
    
    func fetchSearchDecks(for searchText: String) async throws -> [SearchResult] {
        do {
            return try await deckService.fetchSearchDecks(for: searchText, userID: userID)
        } catch {
            throw DataManagerError.deckFetchError(error: error)
        }
    }
    
    // MARK: - Deck CRUD Methods
    func addSubdeckIDs(subdeckIDs: [String], toParentDeckID: String) async throws {
        let parentDeckUpdates = [DeckUpdate.subdeckIDs(IDUpdate(addIDs: subdeckIDs))]
        try await updateDeck(updates: parentDeckUpdates, for: toParentDeckID)
    }
    
    func deleteSubdeckIDs(subdeckIDs: [String], fromParentDeckID: String) async throws {
        let parentDeckUpdates = [DeckUpdate.subdeckIDs(IDUpdate(removeIDs: subdeckIDs))]
        try await updateDeck(updates: parentDeckUpdates, for: fromParentDeckID)
        
        await subdeckCache.deleteItems(ids: subdeckIDs)
    }
    
    func updateDeckUpdatedDate(for id: String) async throws {
        let deckUpdates: [DeckUpdate] = [.updatedDate(Date())]
        try await deckService.updateDeck(id: id, deckUpdates: deckUpdates)
    }
    
    func createDeck(deck: Deck) async throws {
        do {
            var updatedDeck = deck
            updatedDeck.userID = userID
            try await deckService.createDeck(deck: updatedDeck)
        } catch {
            
            throw DataManagerError.deckSaveError(error: error)
        }
    }
    
    func deleteDeck(by id: String) async throws {
        do {
            try await deckService.deleteDeck(id: id)
            
            await deckCache.deleteItems(ids: [id])
            await subdeckCache.deleteItems(ids: [id])
        } catch {
            throw DataManagerError.deckDeleteError(error: error)
        }
    }
    
    func deleteDeckAndAssociatedData(id: String) async throws {
        guard let deck = try await fetchDeck(for: id) else { return }
        if deck.parentDeckID == nil {
            if !deck.subdeckIDs.isEmpty {
                for subdeckID in deck.subdeckIDs {
                    do {
                        if let subdeck = try await fetchDeck(for: subdeckID), !subdeck.flashcardIDs.isEmpty {
                            try await deleteBatchFlashcards(ids: subdeck.flashcardIDs)
                        }
                        try await deleteDeck(by: subdeckID)
                    } catch {
                        throw error
                    }
                }
            }
        }
        if !deck.flashcardIDs.isEmpty {
            try await deleteBatchFlashcards(ids: deck.flashcardIDs)
        }
        if let subdeck = try await fetchDeck(for: id), let parentDeckID = subdeck.parentDeckID {
            try await deleteSubdeckIDs(subdeckIDs: [id], fromParentDeckID: parentDeckID)
        }
        try await deleteDeck(by: id)
        
        if deck.parentDeckID != nil {
            await deckCache.deleteItems(ids: [id])
            await subdeckCache.clearCache()
        } else {
            await subdeckCache.deleteItems(ids: [id])
        }
    }
    
    private func deleteBatchFlashcards(ids: [String]) async throws {
        if !ids.isEmpty {
            for flashcardID in ids {
                do {
                    try await deleteFlashcard(by: flashcardID)
                } catch {
                    AppLogger.logError("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateDeck(updates: [DeckUpdate], for id: String) async throws {
        do {
            try await deckService.updateDeck(id: id, deckUpdates: updates)
            try await updateDeckUpdatedDate(for: id)
            await deckCache.deleteItems(ids: [id])
        } catch {
            throw DataManagerError.deckEditError(error: error)
        }
    }
    
    func updateDeck(newDeck: Deck) async throws {
        do {
            try await deckService.updateDeck(deck: newDeck)
            try await updateDeckUpdatedDate(for: newDeck.id)
            await deckCache.deleteItems(ids: [newDeck.id])
        } catch {
            throw DataManagerError.deckEditError(error: error)
        }
    }
    
    func isDeckNameAvailable(deckName: String) async throws -> Bool {
        do {
            return try await deckService.isDeckNameAvailable(deckName: deckName, userID: userID)
        } catch {
            
            throw DataManagerError.deckFetchError(error: error)
        }
    }
    
    // MARK: - Flashcard Fetch Methods
    func fetchSearchFlashcards(for searchText: String) async throws -> [SearchResult] {
        do {
            let flashcards = try await flashcardService.fetchSearchFlashcards(for: searchText, userID: userID)
            var searchResults: [SearchResult] = []
            for flashcard in flashcards {
                if let deck = try await fetchDeck(for: flashcard.deckID) {
                    searchResults.append(SearchResult(flashcard: flashcard, deckName: deck.name, theme: deck.theme))
                }
            }
            return searchResults
        } catch {
            throw DataManagerError.flashcardFetchError(error: error)
        }
    }
    
    func fetchAllFlashcards(flashcardLimit: Int? = nil) async throws -> [Flashcard] {
        do {
            return try await flashcardService.fetchAllFlashcards(userID: userID, documentLimit: flashcardLimit)
        } catch {
            
            throw DataManagerError.flashcardFetchError(error: error)
        }
    }
    
    func fetchFlashcards(forDeckID: String) async throws -> [Flashcard] {
        let predicates: [QueryPredicate] = [
            .isEqualTo(field: "deckID", value: forDeckID)
        ]
        return try await flashcardService.query(predicates: predicates, userID: userID)
    }
    
    func fetchFlashcard(id: String) async throws -> Flashcard? {
        return try await flashcardService.fetchFlashcard(id: id)
    }
    
    func fetchFlashcards(ids: [String]) async throws -> [Flashcard] {
        return try await flashcardService.fetchFlashcards(ids: ids)
    }
    
    func fetchRandomFlashcards() async throws -> [Flashcard] {
        return try await flashcardService.fetchRandomFlashcards(userID: userID)
    }
    
    //MARK: - Flashcard CRUD Methods
    func updateFlashcardUpdatedDate(id: String) async throws {
        let flashcardUpdates: [FlashcardUpdate] = [.updatedDate(Date())]
        try await flashcardService.updateFlashcard(id: id, flashcardUpdates: flashcardUpdates)
    }
    
    func createFlashcard(flashcard: Flashcard) async throws {
        var updatedFlashcard = flashcard
        updatedFlashcard.userID = userID
        try await flashcardService.createFlashcard(flashcard: updatedFlashcard)
        
        // Update for Deck
        let deckUpdate = [DeckUpdate.flashcardIDs(IDUpdate(addIDs: [flashcard.id]))]
        try await updateDeck(updates: deckUpdate, for: flashcard.deckID)
    }
    
    func deleteFlashcard(by id: String) async throws {
        if let flashcard = try await flashcardService.fetchFlashcard(id: id) {
            let deckUpdate = [DeckUpdate.flashcardIDs(IDUpdate(removeIDs: [id]))]
            try await updateDeck(updates: deckUpdate, for: flashcard.deckID)
        }
        try await flashcardService.deleteFlashcard(id: id)
        await flashcardCache.deleteItems(ids: [id])
    }
    
    func updateFlashcard(updates: [FlashcardUpdate], for id: String) async throws {
        try await flashcardService.updateFlashcard(id: id, flashcardUpdates: updates)
        try await updateFlashcardUpdatedDate(id: id)
        await flashcardCache.deleteItems(ids: [id])
    }
    
    func updateFlashcard(flashcard: Flashcard) async throws {
        try await flashcardService.updateFlashcard(flashcard: flashcard)
        try await updateFlashcardUpdatedDate(id: flashcard.id)
        await flashcardCache.deleteItems(ids: [flashcard.id])
    }
    
    // MARK: - Dynamic Data Retrievals
    func loadParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        do {
            let parentDecks = try await fetchAllParentDecks()
            let subdecks = try await fetchAllSubDecks()
            let subdecksByParentID = Dictionary(grouping: subdecks, by: { $0.parentDeckID })
            let decksWithSubdecks: [(Deck, [Deck])] = parentDecks.map { parentDeck -> (Deck, [Deck]) in
                let subdecks = subdecksByParentID[parentDeck.id] ?? []
                return (parentDeck, subdecks)
            }
            return decksWithSubdecks
        } catch {
            throw AppError.networkError
        }
    }
    
    func loadDecksWithFlashcards(deckIDs: [String]) async throws -> [(Deck, [Flashcard])] {
        do {
            let decks = try await fetchDecks(ids: deckIDs)
            var results: [(Deck, [Flashcard])] = []
            
            for deck in decks {
                let flashcards = try await fetchFlashcards(forDeckID: deck.id)
                guard !flashcards.isEmpty else { continue }
                results.append((deck, flashcards))
            }
            return results
        } catch {
            AppLogger.logError("\(error.localizedDescription)")
        }
        return []
    }
    
    // MARK: - Review Session Summary Methods
    func fetchAllReviewSessionSummaries() async throws -> [ReviewSessionSummary] {
        return try await reviewSessionSummaryService.fetchAllReviewSessionSummaries(userID: userID)
    }
    
    func fetchReviewSessionSummaries(for date: Date) async throws -> [ReviewSessionSummary] {
        return try await reviewSessionSummaryService.fetchReviewSessionSummaries(for: date, userID: userID)
    }
    
    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws {
        var updatedReviewSessionSummary = reviewSessionSummary
        updatedReviewSessionSummary.userID = userID
        return try await reviewSessionSummaryService.createReviewSessionSummary(updatedReviewSessionSummary)
    }
    
    func calculateStreak(startDate: Date) async throws -> Int {
        return try await reviewSessionSummaryService.calculateStreak(startDate: startDate, userID: userID)
    }
    
    func deleteAllUserData() async throws {
        try await reviewSessionSummaryService.deleteAllReviewSummaries(userID: userID)
        let parentDecks = try await fetchAllParentDecks()
        for deck in parentDecks {
            try await deleteDeckAndAssociatedData(id: deck.id)
        }
    }
}
