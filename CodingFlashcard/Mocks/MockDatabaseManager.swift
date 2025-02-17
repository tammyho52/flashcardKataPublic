//
//  MockDatabaseManager.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

#if DEBUG
class MockDatabaseManager: ObservableObject, DatabaseManagerProtocol {
    
    @Published var decks: [Deck] = []
    @Published var flashcards: [Flashcard] = []
    @Published var reviewSessionSummaries: [ReviewSessionSummary] = []
    @Published var errorMessage: String?
    
    var userID: String = UUID().uuidString
    
    init() {
        Task {
            try? await loadInitialData()
        }
    }
    
    func isGuestUser() -> Bool {
        return false
    }
    
    func navigateToSignInWithoutAccount() {
        return // Will not mock for this function
    }
    
    func loadInitialData() async throws {
        decks = Deck.allSampleDecks
        flashcards = Flashcard.sampleFlashcardArray
        reviewSessionSummaries = ReviewSessionSummary.sampleArray
    }
    
    // MARK: - Deck Methods
    func fetchInitialParentDecks() async throws -> [Deck] {
        return Deck.sampleDeckArray // returns all at once
    }
    
    func fetchMoreParentDecks(lastDeckID: String) async throws -> [Deck] {
        return [] // Will not return additional decks for mock
    }
    
    func fetchSubdecks(for subdeckIDs: [String]) async throws -> [Deck] {
        return Deck.sampleSubdeckArray // returns all at once
    }
    
    func fetchAllParentDecks(deckCountLimit: Int? = nil) async throws-> [Deck] {
        return Deck.sampleDeckArray
    }
    
    func fetchAllSubDecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return Deck.sampleSubdeckArray
    }
    
    func fetchDeck(for id: String) async throws -> Deck? {
        if let index = decks.firstIndex(where: { $0.id == id }) {
            return decks[index]
        }
        return nil
    }
    
    func fetchDecks(ids: [String]) async throws -> [Deck] {
        return decks.filter { ids.contains($0.id) }
    }
    
    func fetchSubDecks(for parentDeckID: String) async throws -> [Deck] {
        return decks.filter { $0.parentDeckID == parentDeckID }
    }
    
    func addSubdeckIDs(subdeckIDs: [String], toParentDeckID: String) async throws {
        if let index = decks.firstIndex(where: { $0.id == toParentDeckID }) {
            decks[index].subdeckIDs.append(contentsOf: subdeckIDs)
        }
    }
    
    func deleteSubdeckIDs(subdeckIDs: [String], fromParentDeckID: String) async throws {
        if let index = decks.firstIndex(where: { $0.id == fromParentDeckID }) {
            decks[index].subdeckIDs.removeAll(where: { subdeckIDs.contains($0) })
        }
    }
     
    /// Includes deck ordering by `orderDecksByParentDeckID`
    func fetchSearchDecks(for searchText: String) async throws -> [SearchResult] {
        var filteredDecks = decks.filter { $0.name.contains(searchText) }
        filteredDecks = orderDecksByParentDeckID(deckList: filteredDecks, orderBy: \.updatedDate, sortOperator: >)
        return filteredDecks.map { SearchResult(deck: $0) }
    }
    
    func createDeck(deck: Deck) async throws {
        decks.append(deck)
    }
    
    func deleteDeck(by id: String) async throws {
        if let index = decks.firstIndex(where: { $0.id == id }) {
            decks.remove(at: index)
        }
    }
    
    func deleteDeckAndAssociatedData(id: String) async throws {
        if let index = decks.firstIndex(where: { $0.id == id }) {
            let deck = decks[index]
            decks.remove(at: index)
            if !deck.subdeckIDs.isEmpty {
                for subdeckID in deck.subdeckIDs {
                    if let subdeck = decks.first(where: { $0.id == subdeckID }) {
                        if !subdeck.flashcardIDs.isEmpty {
                            flashcards.removeAll(where: { subdeck.flashcardIDs.contains($0.id) })
                        }
                    }
                }
                decks.removeAll(where: { deck.subdeckIDs.contains($0.id) })
            }
        }
    }
    
    func updateDeck(updates: [DeckUpdate], for id: String) async throws {
        if var deck = try await fetchDeck(for: id) {
            for update in updates {
                switch update {
                case .name(let newName):
                    deck.name = newName
                case .theme(let newTheme):
                    deck.theme = newTheme
                case .parentDeckID(let newParentDeckID):
                    deck.parentDeckID = newParentDeckID
                case .subdeckIDs(let idUpdate):
                    deck.subdeckIDs.append(contentsOf: idUpdate.addIDs)
                    deck.subdeckIDs.removeAll(where: { idUpdate.removeIDs.contains($0) })
                case .flashcardIDs(let idUpdate):
                    deck.flashcardIDs.append(contentsOf: idUpdate.addIDs)
                    deck.flashcardIDs.removeAll(where: { idUpdate.removeIDs.contains($0) })
                case .lastReviewedDate(let newLastReviewedDate):
                    deck.lastReviewedDate = newLastReviewedDate
                case .updatedDate(let newUpdatedDate):
                    deck.updatedDate = newUpdatedDate
                }
            }
        }
    }

    func updateDeck(newDeck: Deck) async throws {
        if let index = decks.firstIndex(where: { $0.id == newDeck.id }) {
            decks[index] = newDeck
        }
    }
    
    func updateDeckUpdatedDate(for id: String) async throws {
        // no mock
    }
    
    func isDeckNameAvailable(deckName: String) async throws -> Bool {
        return !decks.contains(where: { $0.name == deckName })
    }    
    
    // MARK: - Flashcard Methods
    func fetchInitialFlashcards(forFlashcardIDs: [String]) async throws -> [Flashcard] {
        return flashcards.filter { forFlashcardIDs.contains($0.id) }
    }
    
    func fetchMoreFlashcards(lastFlashcardID: String, forFlashcardIDs: [String]) async throws -> [Flashcard] {
        return [] // Did not mock
    }
    
    func fetchAllFlashcards(flashcardLimit: Int? = nil) async throws -> [Flashcard] {
        return flashcards
    }
    
    func fetchFlashcards(forDeckID: String) async throws -> [Flashcard] {
        return flashcards.filter { $0.deckID == forDeckID }
    }
    
    func fetchFlashcards(ids: [String]) async throws -> [Flashcard] {
        return flashcards.filter { ids.contains($0.id) }
    }
    
    func fetchSearchFlashcards(for searchText: String) async throws -> [SearchResult] {
        var filteredFlashcards = try await filterSearchFlashcards(for: searchText)
        filteredFlashcards = orderFlashcardsByUpdatedDate(flashcards: flashcards)
        
        var searchResults: [SearchResult] = []
        for flashcard in filteredFlashcards {
            if let deck = decks.first(where: { $0.id == flashcard.deckID }) {
                searchResults.append(SearchResult(flashcard: flashcard, deckName: deck.name, theme: deck.theme))
            }
        }
        return searchResults
    }
    
    func fetchRandomFlashcards() async throws -> [Flashcard] {
        return flashcards.shuffled()
    }
    
    func filterSearchFlashcards(for searchText: String) async throws -> [Flashcard] {
        return flashcards.filter { $0.frontText.contains(searchText) || $0.backText.contains(searchText) }
    }
    
    func createFlashcard(flashcard: Flashcard) async throws {
        flashcards.append(flashcard)
        let deckUpdate = [DeckUpdate.flashcardIDs(IDUpdate(addIDs: [flashcard.id])), DeckUpdate.updatedDate(Date())]
        try await updateDeck(updates: deckUpdate, for: flashcard.deckID)
    }
    
    func deleteFlashcard(by id: String) async throws {
        if let index = flashcards.firstIndex(where: { $0.id == id }) {
            flashcards.remove(at: index)
        }
    }
    
    func updateFlashcard(updates: [FlashcardUpdate], for id: String) async throws {
        if var flashcard = try await fetchFlashcard(id: id) {
            for update in updates {
                switch update {
                case .deckID(let newDeckID):
                    flashcard.deckID = newDeckID
                case .frontText(let newFrontText):
                    flashcard.frontText = newFrontText
                case .backText(let newBackText):
                    flashcard.backText = newBackText
                case .hint(let newHint):
                    flashcard.hint = newHint
                case .notes(let newNotes):
                    flashcard.notes = newNotes
                case .difficultyLevel(let newDifficultyLevel):
                    flashcard.difficultyLevel = newDifficultyLevel
                case .updatedDate(let newUpdatedDate):
                    flashcard.updatedDate = newUpdatedDate
                case .recentReviewedDate(let newRecentReviewedDate):
                    flashcard.recentReviewedDate = newRecentReviewedDate
                }
            }
        }
    }
    
    func fetchFlashcard(id: String) async throws -> Flashcard? {
        return flashcards.first(where: { $0.id == id })
    }
    
    func updateFlashcard(flashcard: Flashcard) async throws {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index] = flashcard
        }
    }
    
    func hasFlashcards() async throws -> Bool {
        return !flashcards.isEmpty
    }
    
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
    func hasReviewSessionSummaries() async throws -> Bool {
        return true
    }
    
    func fetchAllReviewSessionSummaries() async throws -> [ReviewSessionSummary] {
        return reviewSessionSummaries
    }
    
    func fetchReviewSessionSummaries(for date: Date) async throws -> [ReviewSessionSummary] {
        return reviewSessionSummaries
    }
    
    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws {
        reviewSessionSummaries.append(reviewSessionSummary)
    }
    
    func calculateStreak(startDate: Date) async throws -> Int {
        return 20
    }
    
    func deleteAllUserData() async throws {
        self.decks.removeAll()
        self.flashcards.removeAll()
        self.reviewSessionSummaries.removeAll()
    }
}

class EmptyMockDatabaseManager: MockDatabaseManager {
    override init() {
        
    }
    
    override func loadInitialData() async throws {
        decks = []
        flashcards = []
    }
    
    override func fetchAllParentDecks(deckCountLimit: Int? = nil) async throws-> [Deck] {
        return []
    }
    
    override func fetchAllSubDecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return []
    }
}
#endif
