//
//  ReviewSessionSummaryService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class is responsible for managing review session summary data in Firebase.

import Foundation

/// A service for managing review session summary data in Firebase.
final class ReviewSessionSummaryService {
    // MARK: - Properties
    private let databaseService: FirestoreService<ReviewSessionSummary, Date>
    
    // MARK: - Initialization
    init() {
        self.databaseService = FirestoreService<ReviewSessionSummary, Date>(
            collectionPathType: .reviewSessionSummary,
            orderByKeyPath: \ReviewSessionSummary.completedDate
        )
    }
    
    /// Fetches all review session summaries for a given user ID.
    func fetchAllReviewSessionSummaries(userID: String) async throws -> [ReviewSessionSummary] {
        return try await databaseService.fetchAll(userID: userID)
    }

    /// Fetches review session summaries for a specific date.
    func fetchReviewSessionSummaries(for date: Date, userID: String) async -> [ReviewSessionSummary] {
        do {
            let startDate = Calendar.current.startOfDay(for: date)
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
            guard let validEndDate = endDate else {
                throw AppError.systemError
            }
            
            let queryPredicates: [QueryPredicate] = [
                QueryPredicate.isGreaterThanOrEqualTo(field: "completedDate", value: startDate),
                QueryPredicate.isLessThan(field: "completedDate", value: validEndDate)
            ]
            return try await databaseService.query(predicates: queryPredicates, userID: userID)
        } catch {
            reportError(error)
            return []
        }
    }

    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws {
        return try await databaseService.create(reviewSessionSummary)
    }

    /// Calculates the streak count based on the start date and user ID.
    func calculateStreak(startDate: Date, userID: String) async -> Int {
        var streakCount = 0
        var targetDate = Calendar.current.startOfDay(for: startDate)
        var isCountStreak: Bool = true

        do {
            while isCountStreak {
                // Check if the review session summary exists for the target date
                if try await queryIfReviewSessionSummaryExists(date: targetDate, userID: userID) {
                    streakCount += 1
                    targetDate = Calendar.current.date(byAdding: .day, value: -1, to: targetDate)!
                } else {
                    // If the review session summary does not exist, stop counting the streak
                    isCountStreak = false
                }
            }
            return streakCount
        } catch {
            reportError(error)
            return streakCount
        }
    }
    
    /// Checks if a review session summary exists for a specific date
    private func queryIfReviewSessionSummaryExists(date: Date, userID: String) async throws -> Bool {
        let adjustedStartDate = Calendar.current.startOfDay(for: date)
        let adjustedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: adjustedStartDate) ?? Date()

        let queryPredicates = [
            QueryPredicate.isGreaterThanOrEqualTo(field: "completedDate", value: adjustedStartDate),
            QueryPredicate.isLessThan(field: "completedDate", value: adjustedEndDate),
            QueryPredicate.limitTo(field: 1)
        ]
        
        return try await databaseService.hasDocument(predicates: queryPredicates, userID: userID)
    }
    
    /// Deletes all review session summaries for a given user ID.
    func deleteAllReviewSummaries(userID: String) async throws {
        try await databaseService.deleteAll(userID: userID)
    }
    
    /// Checks if there are any review session summaries for a given user ID.
    func hasReviewSessionSummaries(userID: String) async -> Bool {
        return await databaseService.hasDocument(userID: userID)
    }
}
