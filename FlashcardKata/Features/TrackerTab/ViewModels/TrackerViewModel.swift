//
//  TrackerViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view model manages the Tracker tab, including fetching review session summaries and calculating session summary statistics.

import Foundation

/// A typealias representing flashcard review results, where the key is the flashcard ID and the value is a boolean indicating correctness.
typealias FlashcardReviewResults = [String: Bool] // Bool = isCorrect

/// A view model for the Tracker tab that manages the review session summaries and statistics.
@MainActor
final class TrackerViewModel: ObservableObject {
    // MARK: - Properties
    @Published var selectedDate = Date()
    @Published var reviewSessionSummaries: [ReviewSessionSummary] = []
    @Published var cardsLearnedCount: Int = 0
    @Published var streakCount: Int = 0
    @Published var timeStudied: String = "0:00"
    @Published var chartItems: [ChartItem] = []

    private let databaseManager: DatabaseManagerProtocol
    
    // MARK: - Initializer
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }

    // MARK: - Guest Methods
    /// This method checks if the user is a guest user.
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }

    /// Navigates to the sign-in screen without an account.
    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }

    // MARK: - Tracker Fetch Methods
    /// Checks if there are any review session summaries available.
    func hasReviewSessionSummaries() async -> Bool {
        await databaseManager.hasReviewSessionSummaries()
    }

    /// Loads data for the Tracker summary view.
    func loadTrackerSummaryViewData() async {
        await fetchReviewSummariesForDate(selectedDate)
        await updateSummaryStatistics()
        await updateCalendarPieChartData()
    }

    /// Fetches all review session summaries from the database.
    private func fetchAllReviewSummaries() async throws -> [ReviewSessionSummary] {
        return try await databaseManager.fetchAllReviewSessionSummaries()
    }
    
    /// Fetches review session summaries for a specific date.
    private func fetchReviewSummariesForDate(_ date: Date) async {
        reviewSessionSummaries = await databaseManager.fetchReviewSessionSummaries(for: date)
    }
    
    /// Fetches deck review statistics for parent decks and their subdecks.
    func fetchDeckReviewStatistics() async throws -> [DeckReviewStatistics: [DeckReviewStatistics]] {
        let parentDecksWithSubdecks: [(Deck, [Deck])] = try await databaseManager.fetchParentDecksWithSubDecks()
        var deckWithSubdecksReviewStatistics: [DeckReviewStatistics: [DeckReviewStatistics]] = [:]
        
        for (parentDeck, subDecks) in parentDecksWithSubdecks {
            let subdeckReviewStatistics = subDecks.map { $0.deckReviewStatistics }
            deckWithSubdecksReviewStatistics[parentDeck.deckReviewStatistics] = subdeckReviewStatistics
        }
        return deckWithSubdecksReviewStatistics
    }
    
    /// Fetches flashcard review statistics for a specific deck.
    func fetchFlashcardReviewStatistics(deckID: String) async throws -> [FlashcardReviewStatistics] {
        let flashcards = try await databaseManager.fetchFlashcardsForDeckID(deckID: deckID)
        return flashcards.map { FlashcardReviewStatistics(flashcard: $0) }
    }

    // MARK: - Card Statistics Update Methods
    /// Updates the summary statistics for the Tracker view.
    private func updateSummaryStatistics() async {
        updateCardsLearnedCount()
        await updateStreakCount()
        updateTimeStudied()
    }
    
    /// Updates the count of cards learned based on the review session summaries.
    private func updateCardsLearnedCount() {
        var cardsLearned: Set<String> = []
        cardsLearned = Set(reviewSessionSummaries.flatMap { $0.flashcardReviewResults.keys })
        self.cardsLearnedCount = cardsLearned.count
    }

    /// Updates the streak count based for the selected date.
    private func updateStreakCount() async {
        streakCount = await databaseManager.calculateStreak(startDate: selectedDate)
    }

    /// Updates the total time studied based on the review session summaries.
    private func updateTimeStudied() {
        let timeStudiedSeconds: [TimeInterval] = reviewSessionSummaries.map {
            $0.completedDate.timeIntervalSince($0.startDate)
        }
        let totalTimeStudiedSeconds = timeStudiedSeconds.reduce(0, +)
        timeStudied = TimeConverter(totalSeconds: Int(totalTimeStudiedSeconds)).formattedNumericTime()
    }
    
    // MARK: - Chart Update Methods
    /// Updates the data for the calendar pie chart, aggregating flashcard and deck review results.
    private func updateCalendarPieChartData() async {
        var flashcardReviewResults: FlashcardReviewResults = [:]
        var deckReviewResults: [Deck: FlashcardReviewResults] = [:]

        flashcardReviewResults = mergeReviewSessionSummaries(reviewSessionSummaries)
        deckReviewResults = await createDeckReviewResults(flashcardReviewResults)
        
        chartItems = createChartItems(from: deckReviewResults)
    }
    
    /// Merges review session summaries into a single flashcard review results dictionary.
    private func mergeReviewSessionSummaries(_ reviewSessionSummaries: [ReviewSessionSummary]) -> FlashcardReviewResults {
        var flashcardReviewResults: FlashcardReviewResults = [:]
        
        // Merges review results for duplicative flashcard IDs, prioritizing correct answers. If a flashcard ID has both correct and incorrect answers, the result is marked as correct.
        for reviewSessionSummary in reviewSessionSummaries {
            flashcardReviewResults = flashcardReviewResults.merging(reviewSessionSummary.flashcardReviewResults) { current, new in
                if current == true || new == true {
                    return true
                } else {
                    return false
                }
            }
        }
        return flashcardReviewResults
    }
    
    /// Adds flashcard review results to their respective decks.
    private func createDeckReviewResults(_ flashcardReviewResults: FlashcardReviewResults) async -> [Deck: FlashcardReviewResults] {
        var deckReviewResults: [Deck: FlashcardReviewResults] = [:]
        var deletedFlashcardReviewResults: FlashcardReviewResults = [:]
        
        for (id, isCorrect) in flashcardReviewResults {
            do {
                if let flashcard = try await databaseManager.fetchFlashcard(id: id),
                   let deck = try await databaseManager.fetchDeck(for: flashcard.deckID) {
                    deckReviewResults[deck, default: [:]][id] = isCorrect
                }
            } catch {
                // Flashcards from deleted decks are added to a consolidated "Deleted Decks" entry.
                deletedFlashcardReviewResults[id] = isCorrect
                reportError(error)
            }
        }
        
        if !deletedFlashcardReviewResults.isEmpty {
            let deletedDeck = Deck(name: "Deleted Decks", theme: .gray)
            deckReviewResults[deletedDeck] = deletedFlashcardReviewResults
        }
        
        return deckReviewResults
    }
    
    /// Creates chart items from deck review results.
    private func createChartItems(from deckReviewResults: [Deck: FlashcardReviewResults]) -> [ChartItem] {
        deckReviewResults.map {
            ChartItem(
                deck: $0.0,
                flashcardReviewResults: $0.1
            )
        }
    }
    
    // MARK: - Other Methods
    /// Fetches the account creation date from the database.
    func getAccountCreationDate() async -> Date {
        do {
            return try await databaseManager.getAccountCreationDate() ?? Date() // Default to current date if nil
        } catch {
            return Date() // Default to current date if error occurs
        }
    }
}
    
