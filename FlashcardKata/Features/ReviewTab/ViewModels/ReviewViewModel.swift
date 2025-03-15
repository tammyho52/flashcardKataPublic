//
//  ReviewViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//

import SwiftUI

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var reviewMode: ReviewMode = .practice
    @Published var flashcardDisplayModels: [FlashcardDisplayModel] = []
    @Published var reviewSettings: ReviewSettings = ReviewSettings.reviewTab
    @Published var flashcardReviewResults: [String: Bool] = [:]
    @Published var hasFlashcards: Bool = false
    @Published var correctScore: Int = 0
    @Published var incorrectScore: Int = 0
    @Published var highStreak: Int = 0
    @Published var reviewSessionSummary: ReviewSessionSummary = ReviewSessionSummary()
    @Published var isTimerEnded: Bool = false
    @Published var shouldReset: Bool = false

    let databaseManager: DatabaseManagerProtocol

    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }

    // MARK: - Guest Methods
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }

    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }

    // MARK: - Database Methods
    func checkForFlashcards() async {
        do {
            hasFlashcards = try await databaseManager.hasFlashcards()
        } catch {
            AppLogger.logError("\(error.localizedDescription)")
        }
    }

    func loadParentDecksWithSubDecks() async throws -> [(Deck, [Deck])] {
        return try await databaseManager.loadParentDecksWithSubDecks()
    }

    func loadDecksWithFlashcards(deckIDs: Set<String>) async throws -> [(Deck, [Flashcard])] {
        let deckIDsArray = Array(deckIDs)
        return try await databaseManager.loadDecksWithFlashcards(deckIDs: deckIDsArray)
    }

    func loadFlashcardDisplayModels() async throws {
        var flashcards: [Flashcard] = []
        if reviewSettings.selectedFlashcardIDs.isEmpty {
            flashcards = try await databaseManager.fetchAllFlashcards(flashcardLimit: nil)
            reviewSettings.selectedFlashcardIDs = Set(flashcards.map(\.id))
        } else {
            flashcards = try await databaseManager.fetchFlashcards(ids: Array(reviewSettings.selectedFlashcardIDs))
        }

        var flashcardDisplayModels: [FlashcardDisplayModel] = []
        for flashcard in flashcards {
            if let deck = try await databaseManager.fetchDeck(for: flashcard.deckID) {
                flashcardDisplayModels.append(
                    FlashcardDisplayModel(flashcard: flashcard, deckNameLabel: deck.deckNameLabel)
                )
            }
        }

        flashcardDisplayModels =
            switch reviewSettings.displayCardSort {
            case .lastUpdated:
                flashcardDisplayModels.sorted(by: { $0.flashcard.updatedDate > $1.flashcard.updatedDate })
            case .byDeck:
                flashcardDisplayModels.sorted(by: {
                    ($0.deckNameLabel.id, $0.flashcard.updatedDate) > ($1.deckNameLabel.id, $1.flashcard.updatedDate)
                })
            case .shuffle:
                flashcardDisplayModels.shuffled()
            }
            self.flashcardDisplayModels = flashcardDisplayModels
    }

    // MARK: Save review session
    private func updateReviewSessionSummary() {
        let numberOfDecks = flashcardDisplayModels.reduce(into: [:]) { result, flashcardModel in
            result[flashcardModel.deckNameLabel.id, default: 0] += 1
        }

        reviewSessionSummary.reviewMode = reviewMode
        reviewSessionSummary.completedDate = Date()
        reviewSessionSummary.correctScore = correctScore
        reviewSessionSummary.incorrectScore = incorrectScore
        reviewSessionSummary.flashcardReviewResults = flashcardReviewResults
        reviewSessionSummary.numberOfFlashcards = flashcardReviewResults.count
        reviewSessionSummary.numberOfDecks = numberOfDecks.count

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

    private func getReviewSessionTimeInSeconds() -> Int {
        return Int(reviewSessionSummary.completedDate.timeIntervalSince(reviewSessionSummary.startDate))
    }

    func saveReviewSessionSummary() async throws {
        updateReviewSessionSummary()
        for flashcardID in reviewSessionSummary.flashcardReviewResults.keys {
            try await databaseManager.updateFlashcard(
                updates: [FlashcardUpdate.recentReviewedDate(reviewSessionSummary.completedDate)],
                for: flashcardID
            )
        }

        let reviewedDisplayModels = flashcardDisplayModels.filter {
            reviewSessionSummary.flashcardReviewResults.keys.contains($0.flashcard.id)
        }
        var reviewedDecks: Set<String> = []
        for displayModel in reviewedDisplayModels {
            reviewedDecks.insert(displayModel.flashcard.deckID)
        }
        for deckID in reviewedDecks {
            try await databaseManager.updateDeck(
                updates: [DeckUpdate.lastReviewedDate(reviewSessionSummary.completedDate)],
                for: deckID
            )
        }

        try await databaseManager.createReviewSessionSummary(reviewSessionSummary)
    }

    // MARK: - Helper Methods
    func clearSelectedFlashcardIDs() {
        reviewSettings.selectedFlashcardIDs.removeAll()
    }

    func resetAllValues() {
        reviewMode = .practice
        flashcardDisplayModels = []
        reviewSettings = ReviewSettings.reviewTab
        correctScore = 0
        incorrectScore = 0
        reviewSessionSummary = ReviewSessionSummary()
        isTimerEnded = false
    }

    func addReviewedFlashcardID(id: String, isCorrect: Bool) async {
        flashcardReviewResults[id] = isCorrect
    }

    func addScore() {
        correctScore += 1
    }

    func subtractScore() {
        incorrectScore += 1
    }

    var completedReviewModeMessage: String {
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
                return """
                    Completed Kata Time:
                    \(TimeConverter(totalSeconds: getReviewSessionTimeInSeconds()).formattedShortTime())
                """
            }
        }
    }
}
