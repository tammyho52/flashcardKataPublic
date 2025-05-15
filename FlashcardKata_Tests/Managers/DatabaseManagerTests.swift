//
//  DatabaseManagerTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing
import FirebaseAuth

@MainActor
struct DatabaseManagerTests {
    
    let databaseManager: DatabaseManager = DatabaseManager(
        deckService: DeckService(),
        flashcardService: FlashcardService(),
        reviewSessionSummaryService: ReviewSessionSummaryService(),
        authenticationManager: AnyAuthenticationManager(authenticationManager: FirebaseAuthenticationManager())
    )
    
    let mockDecks = Deck.allSampleDecks
    let mockFlashcards = Flashcard.sampleFlashcardArray
    
    func databaseSetup() async throws {
        if Auth.auth().currentUser == nil {
            try await Auth.auth().createUser(withEmail: "test@example.com", password: "password")
            try await Auth.auth().signIn(withEmail: "test@example.com", password: "password")
        }
        try await Task.sleep(for: .seconds(2))
        try await databaseManager.loadInitialData()
        if await databaseManager.hasFlashcards() == false {
            for deck in mockDecks {
                try? await databaseManager.createDeck(deck: deck)
            }
            for flashcard in mockFlashcards {
                try? await databaseManager.createFlashcard(flashcard: flashcard)
            }
        }
    }
    
    @Test func testFetchDecksWithFlashcards() async throws {
        Task {
            try await databaseSetup()
            let deckIDs = Array(Dictionary(grouping: mockFlashcards, by: { $0.deckID }).keys)
            
            try await Task.sleep(for: .seconds(2))
            
            let expected: [(Deck, [Flashcard])] = {
                var filteredDecks = mockDecks.filter { deckIDs.contains($0.id) }
                filteredDecks.sort { $0.updatedDate > $1.updatedDate }
                var results: [(Deck, [Flashcard])] = []
                for deck in filteredDecks {
                    var flashcards = mockFlashcards.filter { $0.deckID == deck.id }
                    guard !flashcards.isEmpty else { continue }
                    flashcards.sort { $0.updatedDate > $1.updatedDate }
                    results.append((deck, flashcards))
                }
                return results
            }()
            
            let results = try await databaseManager.fetchDecksWithFlashcards(deckIDs: deckIDs)
            
            #expect(results.count == expected.count)
            #expect(results.allSatisfy { deckIDs.contains($0.0.id) })
            if !results.isEmpty {
                #expect(results[0].1.count == expected[0].1.count)
                #expect(results[0].1[0] == expected[0].1[0])
            }
        }
    }
    
    @Test func testLoadFlashcardDisplayModels_noSelectedFlashcardIDs() async throws {
        Task {
            try await databaseSetup()
            
            let mockFlashcardIDs: Set<String> = []
            let results = try await databaseManager.loadFlashcardDisplayModels(
                flashcardIDs: mockFlashcardIDs,
                flashcardLimit: nil,
                displayCardSort: .lastUpdated
            )
            #expect(results.count == mockFlashcards.count)
        }
    }
    
    @Test func testLoadFlashcardDisplayModels_hasSelectedFlashcardIDs() async throws {
        Task {
            try await databaseSetup()
            
            let mockFlashcardIDs = Set(mockFlashcards[0...2].map { $0.id })
            let results = try await databaseManager.loadFlashcardDisplayModels(
                flashcardIDs: mockFlashcardIDs,
                flashcardLimit: nil,
                displayCardSort: .lastUpdated
            )
            #expect(results.count == mockFlashcardIDs.count)
            #expect(results.allSatisfy { mockFlashcardIDs.contains($0.flashcard.id) })
            #expect(results == results.sorted { $0.flashcard.updatedDate > $1.flashcard.updatedDate })
        }
    }
    
    @Test func testDeleteDeckAndAssociatedData() async throws {
        Task {
            try await databaseSetup()
            var mockParentDeck = Deck(id: "MockParentDeck", userID: Auth.auth().currentUser?.uid, name: "Mock Name", theme: .blue, parentDeckID: nil, subdeckIDs: [], flashcardIDs: [], reviewedFlashcardIDs: [], lastReviewedDate: nil, createdDate: Date(), updatedDate: Date())
            let mockSubdeck = Deck(id: "MockSubdeck", userID: Auth.auth().currentUser?.uid, name: "Mock Name", theme: .blue, parentDeckID: mockParentDeck.id, subdeckIDs: [], flashcardIDs: [], reviewedFlashcardIDs: [], lastReviewedDate: nil, createdDate: Date(), updatedDate: Date())
            mockParentDeck.subdeckIDs.append(mockSubdeck.id)
            let mockFlashcard = Flashcard(deckID: mockSubdeck.id)
            
            try await databaseManager.createDeck(deck: mockParentDeck)
            try await databaseManager.createDeck(deck: mockSubdeck)
            try await databaseManager.createFlashcard(flashcard: mockFlashcard)
            
            #expect(try await databaseManager.fetchDeck(for: mockParentDeck.id) != nil)
            #expect(try await databaseManager.fetchDeck(for: mockSubdeck.id) != nil)
            #expect(try await databaseManager.fetchFlashcard(id: mockFlashcard.id) != nil)
            
            try await databaseManager.deleteDeckAndAssociatedData(id: mockParentDeck.id)
            #expect(try await databaseManager.fetchDeck(for: mockParentDeck.id) == nil)
            #expect(try await databaseManager.fetchDeck(for: mockSubdeck.id) == nil)
            #expect(try await databaseManager.fetchFlashcard(id: mockFlashcard.id) == nil)
        }
    }
}
