//
//  ReviewViewModelTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing
import Foundation

@MainActor
struct ReviewViewModelTests {
    @Test func testUpdateReviewSessionSummaryWithResults() async throws {
        let databaseManager = MockDatabaseManager()
        let viewModel = ReviewViewModel(databaseManager: databaseManager)
        
        let decks = Deck.allSampleDecks
        let sampleDisplayModels = FlashcardDisplayModel.sampleArray
        let selectedReviewMode = ReviewMode.target
        let correctScore = 1
        let incorrectScore = sampleDisplayModels.count - 1
        let flashcardReviewResults: [String: Bool] = {
            var isCorrect: Bool = true
            var results: [String: Bool] = [:]
            for flashcardDisplayModel in sampleDisplayModels {
                isCorrect.toggle()
                results[flashcardDisplayModel.flashcard.id] = isCorrect
            }
            return results
        }()
        let targetCorrectCount = sampleDisplayModels.count
        let preUpdateReviewSessionSummary = viewModel.reviewSessionSummary
        
        databaseManager.decks = decks
        viewModel.flashcardDisplayModels = sampleDisplayModels
        viewModel.reviewMode = selectedReviewMode
        viewModel.correctScore = correctScore
        viewModel.incorrectScore = incorrectScore
        viewModel.flashcardReviewResults = flashcardReviewResults
        viewModel.reviewSettings.targetCorrectCount = targetCorrectCount
        
        viewModel.updateReviewSessionSummaryWithResults()
        #expect(viewModel.reviewSessionSummary.startDate == preUpdateReviewSessionSummary.startDate)
        #expect(viewModel.reviewSessionSummary.reviewMode == selectedReviewMode)
        #expect(viewModel.reviewSessionSummary.completedDate != nil)
        #expect(viewModel.reviewSessionSummary.correctScore == correctScore)
        #expect(viewModel.reviewSessionSummary.incorrectScore == incorrectScore)
        #expect(viewModel.reviewSessionSummary.flashcardReviewResults == flashcardReviewResults)
        #expect(viewModel.reviewSessionSummary.numberOfFlashcards == sampleDisplayModels.count)
    }
}

