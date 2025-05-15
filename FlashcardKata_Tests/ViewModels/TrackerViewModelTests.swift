//
//  TrackerViewModelTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing

@MainActor
struct TrackerViewModelTests {
    
    private func sleepForSetup() async {
        try? await Task.sleep(for: .seconds(1))
    }

    @Test func testIsGuestUser() async throws {
        let mockDatabaseManager = MockDatabaseManager()
        let viewModel = TrackerViewModel(databaseManager: mockDatabaseManager)
        let isGuestUser = viewModel.isGuestUser()
        #expect(isGuestUser == false)
    }
    
    @Test func testCheckForReviewSessionSummaries() async throws {
        let mockDatabaseManager = MockDatabaseManager()
        let viewModel = TrackerViewModel(databaseManager: mockDatabaseManager)
        
        await sleepForSetup()
        let hasReviewSessionSummaries: Bool = await viewModel.hasReviewSessionSummaries()
        #expect (hasReviewSessionSummaries == true)
    }
    
    @Test func testLoadTrackerSummaryViewData_hasReviewSessionSummaries() async throws {
        let mockDatabaseManager = MockDatabaseManager()
        let viewModel = TrackerViewModel(databaseManager: mockDatabaseManager)
        
        await sleepForSetup()
        await viewModel.loadTrackerSummaryViewData()
        
        await sleepForSetup()
        #expect(viewModel.reviewSessionSummaries.count == 3)
        #expect(viewModel.cardsLearnedCount == 8)
        #expect(viewModel.streakCount == 20)
        #expect(viewModel.timeStudied == "0:30")
        #expect(viewModel.chartItems.count == 3)
    }
    
    @Test func testLoadTrackerSummaryViewData_noReviewSessionSummaries() async throws {
        let emptyMockDatabaseManager = EmptyMockDatabaseManager()
        let viewModel = TrackerViewModel(databaseManager: emptyMockDatabaseManager)
        
        await sleepForSetup()
        await viewModel.loadTrackerSummaryViewData()
        
        await sleepForSetup()
        #expect(viewModel.reviewSessionSummaries.count == 0)
        #expect(viewModel.cardsLearnedCount == 0)
        #expect(viewModel.streakCount == 20)
        #expect(viewModel.timeStudied == "0:00")
        #expect(viewModel.chartItems.count == 0)
    }
    
    @Test func testFetchDeckReviewStatistics() async throws {
        let mockDatabaseManager = MockDatabaseManager()
        let viewModel = TrackerViewModel(databaseManager: mockDatabaseManager)
        
        await sleepForSetup()
        let deckReviewStatistics = try await viewModel.fetchDeckReviewStatistics()
        
        await sleepForSetup()
        #expect(deckReviewStatistics.count == 3)
        #expect(deckReviewStatistics[Deck.sampleDeckArray[0].deckReviewStatistics]?.count == 2)
        #expect(deckReviewStatistics[Deck.sampleDeckArray[0].deckReviewStatistics] == MockData.greSubdecks.map { $0.deckReviewStatistics })
        #expect(deckReviewStatistics[Deck.sampleDeckArray[1].deckReviewStatistics]?.count == 3)
        #expect(deckReviewStatistics[Deck.sampleDeckArray[1].deckReviewStatistics] == MockData.swiftCodingSubdecks.map { $0.deckReviewStatistics })
        #expect(deckReviewStatistics[Deck.sampleDeckArray[2].deckReviewStatistics]?.count == 2)
        #expect(deckReviewStatistics[Deck.sampleDeckArray[2].deckReviewStatistics] == MockData.japaneseSubdecks.map { $0.deckReviewStatistics })
    }
    
    @Test func testFetchFlashcardReviewStatistics_validDeckID() async throws {
        let mockDatabaseManager = MockDatabaseManager()
        let viewModel = TrackerViewModel(databaseManager: mockDatabaseManager)
        let validDeckID = MockData.deck2.id
        
        await sleepForSetup()
        let flashcardReviewStatistics = try await viewModel.fetchFlashcardReviewStatistics(deckID: validDeckID)
        
        await sleepForSetup()
        #expect(flashcardReviewStatistics.count == 2)
        #expect(flashcardReviewStatistics[0].id == MockData.flashcard18.id)
        #expect(flashcardReviewStatistics[1].id == MockData.flashcard19.id)
    }
    
    @Test func testFetchFlashcardReviewStatistics_invalidDeckID() async throws {
        let mockDatabaseManager = MockDatabaseManager()
        let viewModel = TrackerViewModel(databaseManager: mockDatabaseManager)
        let invalidDeckID = "invalidDeckID"
        
        await sleepForSetup()
        let flashcardReviewStatistics = try await viewModel.fetchFlashcardReviewStatistics(deckID: invalidDeckID)
        
        await sleepForSetup()
        #expect(flashcardReviewStatistics.count == 0)
    }
}
