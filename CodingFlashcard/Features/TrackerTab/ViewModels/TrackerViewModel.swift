//
//  TrackerViewModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation
import Combine

@MainActor
final class TrackerViewModel: ObservableObject {
    @Published var date = Date()
    @Published var hasReviewSessionSummaries: Bool = false
    @Published var reviewSessionSummaries: [ReviewSessionSummary] = []
    @Published var cardsLearnedCount: Int = 0
    @Published var streakCount: Int = 0
    @Published var timeStudied: String = "0:00"
    @Published var chartItems: [ChartItem] = []
    
    private let databaseManager: DatabaseManagerProtocol
    
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
    
    // MARK: Tracker Methods
    func checkForReviewSessionSummaries() async {
        do {
            hasReviewSessionSummaries = try await databaseManager.hasReviewSessionSummaries()
        } catch {
            AppLogger.logError("\(error.localizedDescription)")
        }
    }
    
    func loadTrackerSummaryViewData() async throws {
        try await fetchReviewSummaries()
        try await updateSummaryStatistics()
        try await updateCalendarPieChartData()
    }
    
    func fetchAllReviewSummaries() async throws {
        reviewSessionSummaries = try await databaseManager.fetchAllReviewSessionSummaries()
    }
    
    func fetchReviewSummaries() async throws {
        reviewSessionSummaries = try await databaseManager.fetchReviewSessionSummaries(for: date)
    }
    
    func updateSummaryStatistics() async throws {
        updateCardsLearnedCount()
        try await updateStreakCount()
        updateTimeStudied()
    }
    
    private func updateCardsLearnedCount() {
        var cardsLearned: Set<String> = []
        cardsLearned = Set(reviewSessionSummaries.flatMap { $0.flashcardReviewResults.keys })
        self.cardsLearnedCount = cardsLearned.count
    }
    
    private func updateStreakCount() async throws {
        streakCount = try await databaseManager.calculateStreak(startDate: date)
    }
    
    private func updateTimeStudied() {
        let timeStudiedSeconds: [TimeInterval] = reviewSessionSummaries.map { $0.completedDate.timeIntervalSince($0.startDate) }
        let totalTimeStudiedSeconds = timeStudiedSeconds.reduce(0, +)
        timeStudied = TimeConverter(totalSeconds: Int(totalTimeStudiedSeconds)).formattedNumericTime()
    }
    
    private func updateCalendarPieChartData() async throws {
        var consolidatedFlashcardIDs: [String: Bool] = [:]
        var deckFlashcardData: [Deck: [String: Bool]] = [:]
     
        for reviewSessionSummary in reviewSessionSummaries {
            consolidatedFlashcardIDs = consolidatedFlashcardIDs.merging(reviewSessionSummary.flashcardReviewResults) { current, new in
                if current == true || new == true {
                    return true
                } else {
                    return false
                }
            }
        }
        
        var deletedFlashcardIDs: [String: Bool] = [:]
        
        for (id, isCorrect) in consolidatedFlashcardIDs {
            do {
                if let flashcard = try await databaseManager.fetchFlashcard(id: id), let deck = try await databaseManager.fetchDeck(for: flashcard.deckID) {
                    deckFlashcardData[deck, default: [:]][id] = isCorrect
                }
            } catch {
                deletedFlashcardIDs[id] = isCorrect
            }
        }
        var consolidatedChartItems: [ChartItem] = deckFlashcardData.map { ChartItem(deck: $0.0, flashcardsReviewed: $0.1) }
        if !deletedFlashcardIDs.isEmpty {
            consolidatedChartItems.append(
                ChartItem(
                    deck: Deck(name: "Deleted", theme: .gray),
                    flashcardsReviewed: deletedFlashcardIDs
                )
            )
        }
        chartItems = consolidatedChartItems
    }
}
