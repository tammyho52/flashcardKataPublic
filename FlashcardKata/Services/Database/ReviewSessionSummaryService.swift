//
//  ReviewSessionSummaryService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Class responsible for managing review session summary data in Firebase.

import Foundation

final class ReviewSessionSummaryService {
    private let collectionPath: String = FirestoreCollectionPath.reviewSessionSummary.path
    private let databaseService: FirestoreService<ReviewSessionSummary, Date>

    init() {
        self.databaseService = FirestoreService<ReviewSessionSummary, Date>(
            collectionPath: collectionPath,
            orderByKeyPath: \ReviewSessionSummary.completedDate,
            orderDirection: .descending
        )
    }

    func fetchAllReviewSessionSummaries(userID: String) async throws -> [ReviewSessionSummary] {
        return try await databaseService.fetchAll(userID: userID)
    }

    func fetchReviewSessionSummaries(for date: Date, userID: String) async throws -> [ReviewSessionSummary] {
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        guard let validEndDate = endDate else { throw AppError.invalidInput(message: "Date is incorrect.") }
        let queryPredicates: [QueryPredicate] = [
            QueryPredicate.isGreaterThanOrEqualTo(field: "completedDate", value: startDate),
            QueryPredicate.isLessThan(field: "completedDate", value: validEndDate)
        ]
        return try await databaseService.query(predicates: queryPredicates, userID: userID)
    }

    func createReviewSessionSummary(_ reviewSessionSummary: ReviewSessionSummary) async throws {
        return try await databaseService.create(reviewSessionSummary)
    }

    func calculateStreak(startDate: Date, userID: String) async throws -> Int {
        var streakCount = 0
        var targetDate = Calendar.current.startOfDay(for: startDate)
        var isCountStreak: Bool = true

        while isCountStreak {
            if try await queryIfReviewSessionSummaryExists(date: targetDate, userID: userID) {
                streakCount += 1
                targetDate = Calendar.current.date(byAdding: .day, value: -1, to: targetDate)!
            } else {
                isCountStreak = false
            }
        }
        return streakCount
    }

    private func queryIfReviewSessionSummaryExists(date: Date, userID: String) async throws -> Bool {
        let adjustedStartDate = Calendar.current.startOfDay(for: date)
        let adjustedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: adjustedStartDate) ?? Date()

        let queryPredicates = [
            QueryPredicate.isGreaterThanOrEqualTo(field: "completedDate", value: adjustedStartDate),
            QueryPredicate.isLessThan(field: "completedDate", value: adjustedEndDate),
            QueryPredicate.limitTo(field: 1)
        ]

        let query = try await databaseService.createQuery(predicates: queryPredicates, userID: userID)
        let snapshot = try await query.getDocuments()
        return !snapshot.isEmpty
    }

    func deleteAllReviewSummaries(userID: String) async throws {
        try await databaseService.deleteAll(userID: userID)
    }

    func hasReviewSessionSummaries(userID: String) async throws -> Bool {
        return try await databaseService.hasDocument(userID: userID)
    }
}
