//
//  MockDatabaseManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates a mock database manager for simulating data operations.

import SwiftUI

#if DEBUG
class MockDatabaseManager: ObservableObject, DatabaseManagerProtocol, DatabaseManagerPublisherProtocol {
    @AppStorage(UserDefaultsKeys.authenticationProvider) private var authenticationProvider: AuthenticationProvider?
    @Published var decks: [Deck] = []
    @Published var subdecks: [Deck] = []
    @Published var flashcards: [Flashcard] = []
    @Published var reviewSessionSummaries: [ReviewSessionSummary] = []
    @Published var errorMessage: String?
    
    private let initialDeckCount = 10 // Returns first 10 decks
    private let initialFlashcardCount = 10 // Returns first 10 flashcards
    
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
    
    var allDecks: [Deck] {
        return decks + subdecks
    }

    var userID: String = UUID().uuidString

    init() {
        Task {
            try? await loadInitialData()
        }
    }

    func isGuestUser() -> Bool {
        authenticationProvider != .guest
    }

    func navigateToSignInWithoutAccount() {
        return // Will not mock for this function
    }
    
    func getAccountCreationDate() async throws -> Date? {
        return Date()
    }

    func loadInitialData() async throws {
        decks = Deck.sampleDeckArray
        subdecks = Deck.sampleSubdeckArray
        flashcards = Flashcard.sampleFlashcardArray
        reviewSessionSummaries = ReviewSessionSummary.sampleArray
    }
    
    func loadFlashcardDisplayModels(flashcardIDs: Set<String>, flashcardLimit: Int?, displayCardSort: CardSort) async throws -> [FlashcardDisplayModel] {
        var loadFlashcards = flashcardIDs.isEmpty ? flashcards : flashcards.filter { flashcardIDs.contains($0.id) }
        loadFlashcards = Array(loadFlashcards.prefix(flashcardLimit ?? flashcards.count))
        
        var flashcardDisplayModels: [FlashcardDisplayModel] = []
        let groupedFlashcards: [String: [Flashcard]] = Dictionary(grouping: loadFlashcards, by: { $0.deckID })
        
        for (deckID, deckFlashcards) in groupedFlashcards {
            if let deck = allDecks.first(where: { $0.id == deckID }) {
                let deckNameLabel = deck.deckNameLabel
                for flashcard in deckFlashcards {
                    let flashcardDisplayModel = FlashcardDisplayModel(flashcard: flashcard, deckNameLabel: deckNameLabel)
                    flashcardDisplayModels.append(flashcardDisplayModel)
                }
            }
        }
        return sortFlashcardDisplayModels(displayCardSort: displayCardSort, flashcardDisplayModels: flashcardDisplayModels)
    }
        

    // MARK: - Deck Methods
    func fetchAllDecks() async throws -> [Deck] {
        return allDecks
    }

    func fetchInitialParentDecks() async throws -> [Deck] {
        return Array(Deck.sampleDeckArray.prefix(initialDeckCount)) // Returns first two decks
    }

    func fetchMoreParentDecks(lastDeckID: String) async throws -> [Deck] {
        return Array(Deck.sampleDeckArray[initialDeckCount...]) // Returns remaining decks
    }

    func fetchAllParentDecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return Deck.sampleDeckArray
    }

    func fetchSubdecks(for subdeckIDs: [String]) async throws -> [Deck] {
        return Deck.sampleSubdeckArray.filter { subdeckIDs.contains($0.id) }
    }

    func fetchAllSubdecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return Deck.sampleSubdeckArray
    }

    func fetchDeck(for id: String) async throws -> Deck? {
        if let index = allDecks.firstIndex(where: { $0.id == id }) {
            return allDecks[index]
        }
        return nil
    }

    func fetchDecks(ids: [String]) async throws -> [Deck] {
        return allDecks.filter { ids.contains($0.id) }
    }

    func fetchSubDecks(for parentDeckID: String) async throws -> [Deck] {
        return allDecks.filter { $0.parentDeckID == parentDeckID }
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

    // Includes deck ordering by `orderDecksByParentDeckID`
    func fetchSearchDecks(for searchText: String) async throws -> [SearchResult] {
        var filteredDecks = allDecks.filter { $0.name.contains(searchText) }
        filteredDecks = orderDecksByParentDeckID(deckList: filteredDecks, orderBy: \.updatedDate, sortOperator: >)
        return filteredDecks.map { SearchResult(deck: $0) }
    }

    func createDeck(deck: Deck) async throws {
        if deck.parentDeckID == nil {
            decks.append(deck)
        } else {
            subdecks.append(deck)
        }
    }

    func deleteDeck(by id: String) async throws {
        if let index = decks.firstIndex(where: { $0.id == id }) {
            decks.remove(at: index)
        } else if let index = subdecks.firstIndex(where: { $0.id == id }) {
            subdecks.remove(at: index)
        }
    }

    func deleteDeckAndAssociatedData(id: String) async throws {
        // Remove parent deck and its associated data
        if let index = decks.firstIndex(where: { $0.id == id }) {
            let deck = decks[index]
            decks.remove(at: index)
            if !deck.subdeckIDs.isEmpty {
                for subdeckID in deck.subdeckIDs {
                    if let subdeck = subdecks.first(where: { $0.id == subdeckID }) {
                        if !subdeck.flashcardIDs.isEmpty {
                            flashcards.removeAll(where: { subdeck.flashcardIDs.contains($0.id) })
                        }
                    }
                }
                subdecks.removeAll(where: { deck.subdeckIDs.contains($0.id) })
            }
        } else if let index = subdecks.firstIndex(where: { $0.id == id }) {
            // Remove subdeck and its associated data
            let subdeck = subdecks[index]
            subdecks.remove(at: index)
            if !subdeck.flashcardIDs.isEmpty {
                flashcards.removeAll(where: { subdeck.flashcardIDs.contains($0.id) })
            }
            if let parentDeckIndex = decks.firstIndex(where: { $0.id == subdeck.parentDeckID }) {
                decks[parentDeckIndex].subdeckIDs.removeAll(where: { $0 == id })
            }
        }
    }

    func updateDeck(updates: [DeckUpdate], for id: String) async throws {
        if let index = decks.firstIndex(where: { $0.id == id }) {
            var deck = decks[index]
            try await updateDeck(updates: updates, for: &deck)
            decks[index] = deck
        } else if let index = subdecks.firstIndex(where: { $0.id == id }) {
            var subdeck = subdecks[index]
            try await updateDeck(updates: updates, for: &subdeck)
            subdecks[index] = subdeck
        }
    }
    
    private func updateDeck(updates: [DeckUpdate], for deck: inout Deck) async throws {
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
            case .reviewedFlashcardIDs(let idUpdate):
                deck.reviewedFlashcardIDs.append(contentsOf: idUpdate.addIDs)
                deck.reviewedFlashcardIDs.removeAll(where: { idUpdate.removeIDs.contains($0) })
            case .lastReviewedDate(let newLastReviewedDate):
                deck.lastReviewedDate = newLastReviewedDate
            case .updatedDate(let newUpdatedDate):
                deck.updatedDate = newUpdatedDate
            }
        }
    }

    func updateDeckWithNewDeck(newDeck: Deck) async throws {
        if newDeck.isSubdeck, let index = subdecks.firstIndex(where: { $0.id == newDeck.id }) {
            subdecks[index] = newDeck
        } else if let index = decks.firstIndex(where: { $0.id == newDeck.id }) {
            decks[index] = newDeck
        }
    }

    func updateDeckUpdatedDate(for id: String) async throws {
        if let index = subdecks.firstIndex(where: { $0.id == id }) {
            var newSubdeck = subdecks[index]
            newSubdeck.updatedDate = Date()
            subdecks[index] = newSubdeck
        } else if let index = decks.firstIndex(where: { $0.id == id }) {
            var newDeck = decks[index]
            newDeck.updatedDate = Date()
            decks[index] = newDeck
        }
    }

    func isDeckNameAvailable(deckName: String) async -> Bool {
        return !allDecks.contains(where: { $0.name == deckName })
    }

    // MARK: - Flashcard Methods
    func fetchInitialFlashcards(forFlashcardIDs: [String]) async throws -> [Flashcard] {
        return Array(flashcards.filter { forFlashcardIDs.contains($0.id) }.prefix(initialFlashcardCount)) // Returns first flashcard
    }

    func fetchMoreFlashcards(lastFlashcardID: String, flashcardIDs: [String]) async throws -> [Flashcard] {
        let fetchedFlashcards = Array(flashcards.filter { flashcardIDs.contains($0.id) })
        if fetchedFlashcards.count > initialFlashcardCount {
            return Array(fetchedFlashcards[initialFlashcardCount...]) // Returns remaining flashcards
        } else {
            return []
        }
    }

    func fetchAllFlashcards(flashcardLimit: Int? = nil) async throws -> [Flashcard] {
        return flashcards
    }

    func fetchFlashcardsForDeckID(deckID: String) async throws -> [Flashcard] {
        return flashcards.filter { $0.deckID == deckID }
    }
    
//    func fetchFlashcardsForDeckID(deckID: String) async throws -> [Flashcard]

    func fetchFlashcards(ids: [String]) async throws -> [Flashcard] {
        return flashcards.filter { ids.contains($0.id) }
    }

    func fetchSearchFlashcards(for searchText: String) async throws -> [SearchResult] {
        var filteredFlashcards = try await filterSearchFlashcards(for: searchText)
        filteredFlashcards = orderFlashcardsByUpdatedDate(flashcards: filteredFlashcards)

        var searchResults: [SearchResult] = []
        for flashcard in filteredFlashcards {
            if let deck = decks.first(where: { $0.id == flashcard.deckID }) {
                searchResults.append(SearchResult(flashcard: flashcard, deckName: deck.name, theme: deck.theme))
            }
        }
        return searchResults
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
                case .correctReviewCount(let newCorrectReviewCount):
                    flashcard.correctReviewCount += newCorrectReviewCount
                case .incorrectReviewCount(let newIncorrectReviewCount):
                    flashcard.incorrectReviewCount += newIncorrectReviewCount
                }
            }
        }
    }

    func fetchFlashcard(id: String) async throws -> Flashcard? {
        return flashcards.first(where: { $0.id == id })
    }

    func updateFlashcardWithNewFlashcard(flashcard: Flashcard) async throws {
        if let index = flashcards.firstIndex(where: { $0.id == flashcard.id }) {
            flashcards[index] = flashcard
        }
    }

    func hasFlashcards() async -> Bool {
        return !flashcards.isEmpty
    }

    func fetchParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        do {
            let parentDecks = try await fetchAllParentDecks()
            let subdecks = try await fetchAllSubdecks()
            let subdecksByParentID = Dictionary(grouping: subdecks, by: \.parentDeckID)
            let decksWithSubdecks: [(Deck, [Deck])] = parentDecks.map { parent in
                let children = subdecksByParentID[parent.id] ?? []
                return (parent, children)
            }
            return decksWithSubdecks
        } catch {
            throw AppError.networkError
        }
    }

    func fetchDecksWithFlashcards(deckIDs: [String]) async throws -> [(Deck, [Flashcard])] {
        do {
            let decks = try await fetchDecks(ids: deckIDs)
            var results: [(Deck, [Flashcard])] = []

            for deck in decks {
                let flashcards = try await fetchFlashcardsForDeckID(deckID: deck.id)
                guard !flashcards.isEmpty else { continue }
                results.append((deck, flashcards))
            }
            return results
        } catch {
            throw AppError.networkError
        }
    }

    // MARK: - Review Session Summary Methods
    func hasReviewSessionSummaries() async -> Bool {
        return !reviewSessionSummaries.isEmpty
    }

    func fetchAllReviewSessionSummaries() async throws -> [ReviewSessionSummary] {
        return reviewSessionSummaries
    }

    func fetchReviewSessionSummaries(for date: Date) async -> [ReviewSessionSummary] {
        return reviewSessionSummaries
    }

    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws {
        reviewSessionSummaries.append(reviewSessionSummary)
    }

    func calculateStreak(startDate: Date) async -> Int {
        return 20 // Hardcoded for testing
    }

    func deleteAllUserData() async throws {
        self.decks.removeAll()
        self.flashcards.removeAll()
        self.reviewSessionSummaries.removeAll()
    }
}

class EmptyMockDatabaseManager: MockDatabaseManager {
    override func loadInitialData() async throws {
        decks = []
        flashcards = []
    }

    override func fetchAllParentDecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return []
    }

    override func fetchAllSubdecks(deckCountLimit: Int? = nil) async throws -> [Deck] {
        return []
    }
}
#endif
