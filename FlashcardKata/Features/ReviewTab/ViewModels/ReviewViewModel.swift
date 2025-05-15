//
//  ReviewViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view model for managing the review session tab, including review settings, review session data, and review session summary.

import SwiftUI

/// View model responsible for managing the review session tab.
@MainActor
final class ReviewViewModel: ObservableObject {
    // MARK: - Properties
    @Published var reviewMode: ReviewMode = .practice
    @Published var flashcardDisplayModels: [FlashcardDisplayModel] = []
    @Published var reviewSettings: ReviewSettings = ReviewSettings.reviewTab
    @Published var flashcardReviewResults: [String: Bool] = [:] // Bool = isCorrect
    @Published var hasFlashcards: Bool = false
    @Published var correctScore: Int = 0
    @Published var incorrectScore: Int = 0
    @Published var highStreak: Int = 0
    @Published var reviewSessionSummary: ReviewSessionSummary = ReviewSessionSummary()
    @Published var isTimerEnded: Bool = false
    @Published var shouldReset: Bool = false

    let databaseManager: DatabaseManagerProtocol

    // MARK: - Initializer
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }
    
    // MARK: - Guest Methods
    /// Check if the user is a guest user.
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }

    /// Navigate to the sign-in screen for guest users.
    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }

    // MARK: - Database Methods
    /// Load initial data for the review session.
    func loadInitialData() async throws {
        self.flashcardDisplayModels = try await loadFlashcardDisplayModels()
    }
    
    /// Check if the user has flashcards in the database.
    func checkForFlashcards() async {
        hasFlashcards = await databaseManager.hasFlashcards()
    }
    
    /// Load parent decks with subdecks from the database.
    func loadParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        return try await databaseManager.fetchParentDecksWithSubDecks()
    }

    /// Load decks with flashcards based on the selected deck IDs.
    func loadDecksWithFlashcards(deckIDs: Set<String>) async throws -> [(Deck, [Flashcard])] {
        let deckIDsArray = Array(deckIDs)
        return try await databaseManager.fetchDecksWithFlashcards(deckIDs: deckIDsArray)
    }

    /// Load flashcards based on the selected flashcard IDs.
    func loadFlashcardDisplayModels() async throws -> [FlashcardDisplayModel] {
        return try await databaseManager.loadFlashcardDisplayModels(
            flashcardIDs: reviewSettings.selectedFlashcardIDs,
            flashcardLimit: nil,
            displayCardSort: reviewSettings.displayCardSort
        )
    }

    // MARK: Save review session
    /// Save the review session summary to the database.
    func saveReviewSessionSummary() async throws {
        updateReviewSessionSummaryWithResults()
        
        // Log flashcard review results to flashcards
        try await updateFlashcardsForReviewResults()
        
        // Log flashcard review results to decks
        try await updateDecksForReviewResults()
        
        // Save the review session summary to the database
        try await databaseManager.createReviewSessionSummary(reviewSessionSummary)
    }
    
    /// Update the review session summary to summarize the review session.
    private func updateReviewSessionSummaryWithResults() {
        let numberOfDecks = flashcardDisplayModels.reduce(into: [:]) { result, flashcardModel in
            result[flashcardModel.deckNameLabel.id, default: 0] += 1
        }
        
        // Update the review session summary
        reviewSessionSummary.reviewMode = reviewMode
        reviewSessionSummary.completedDate = Date()
        reviewSessionSummary.correctScore = correctScore
        reviewSessionSummary.incorrectScore = incorrectScore
        reviewSessionSummary.flashcardReviewResults = flashcardReviewResults
        reviewSessionSummary.numberOfFlashcards = flashcardReviewResults.count
        reviewSessionSummary.numberOfDecks = numberOfDecks.count
        
        // Set the review session summary based on the review mode
        switch reviewMode {
        case .target:
            reviewSessionSummary.targetCorrectCount = reviewSettings.targetCorrectCount
        case .streak:
            reviewSessionSummary.streakCount = highStreak
        case .timed:
            if isTimerEnded, let sessionTime = reviewSettings.sessionTime {
                reviewSessionSummary.sessionTimeInSeconds = sessionTime.seconds
            } else {
                reviewSessionSummary.sessionTimeInSeconds = getReviewSessionTimeInSeconds()
            }
        case .practice:
            break
        }
    }
    
    /// Update the flashcards with the review results.
    private func updateFlashcardsForReviewResults() async throws {
        for (flashcardID, isCorrect) in reviewSessionSummary.flashcardReviewResults {
            // Update the flashcard with the recent reviewed date and increment the review count
            let incrementUpdate: FlashcardUpdate = isCorrect ? .correctReviewCount(1) : .incorrectReviewCount(1)
            try await databaseManager.updateFlashcard(
                updates: [
                    FlashcardUpdate.recentReviewedDate(reviewSessionSummary.completedDate),
                    incrementUpdate
                ],
                for: flashcardID
            )
        }
    }
    
    /// Update the decks with the review results.
    private func updateDecksForReviewResults() async throws {
        let reviewedDisplayModels = flashcardDisplayModels.filter {
            reviewSessionSummary.flashcardReviewResults.keys.contains($0.flashcard.id)
        }
        var reviewedDecksWithFlashcards: [String: [String]] = [:]
        for displayModel in reviewedDisplayModels {
            reviewedDecksWithFlashcards[displayModel.flashcard.deckID, default: []].append(displayModel.flashcard.id)
        }
        for (deckID, flashcardIDs) in reviewedDecksWithFlashcards {
            try await databaseManager.updateDeck(
                updates: [
                    DeckUpdate.lastReviewedDate(reviewSessionSummary.completedDate),
                    DeckUpdate.reviewedFlashcardIDs(IDUpdate(addIDs: flashcardIDs))
                ],
                for: deckID
            )
        }
    }

    // MARK: - General Methods
    private func getReviewSessionTimeInSeconds() -> Int {
        return Int(reviewSessionSummary.completedDate.timeIntervalSince(reviewSessionSummary.startDate))
    }
    
    /// Clears the selected flashcard IDs from the review settings.
    func clearSelectedFlashcardIDs() {
        reviewSettings.selectedFlashcardIDs.removeAll()
    }

    /// Resets the review session parameters to their initial values.
    func resetAllValues() {
        reviewMode = .practice
        reviewSettings = ReviewSettings.reviewTab
        flashcardReviewResults = [:]
        correctScore = 0
        incorrectScore = 0
        highStreak = 0
        reviewSessionSummary = ReviewSessionSummary()
        isTimerEnded = false
    }

    /// Records the user's answer result for a specific flashcard.
    /// - Parameters:
    ///   - id: The ID of the flashcard.
    ///   - isCorrect: Whether the user's answer was correct.
    func addReviewedFlashcardID(id: String, isCorrect: Bool) async {
        flashcardReviewResults[id] = isCorrect
    }
    
    /// Increments the correct score by 1.
    func addScore() {
        correctScore += 1
    }

    /// Increments the incorrect score by 1.
    func subtractScore() {
        incorrectScore += 1
    }
    
    /// Generates a review session summary message based on the review mode and other parameters.
    /// - Returns: A string representing the review session summary message.
    func getCompletionReviewMessage() -> String {
        switch reviewMode {
        case .practice:
            return "Practice Kata completed!"
        case .target:
            if let targetCorrectCount = reviewSessionSummary.targetCorrectCount {
               if correctScore == targetCorrectCount {
                   return "Completed maximum target of \(targetCorrectCount) correct answers"
               } else {
                   return "Didn't meet maximum target of \(targetCorrectCount) correct answers"
               }
            } else {
                return "Target Kata completed!"
            }
        case .streak:
            return "High Streak: \(highStreak)"
        case .timed:
            if isTimerEnded, let sessionTime = reviewSettings.sessionTime {
                return "Completed Kata Time: \(sessionTime.rawValue)"
            } else {
                let totalSeconds = getReviewSessionTimeInSeconds()
                let formattedTime = TimeConverter(totalSeconds: totalSeconds).formattedShortTime()
                return "Completed Kata Time: \(formattedTime)"
            }
        }
    }
}
