//
//  ReviewSessionSummary.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model representing a flashcard review session that stores session details.

import Foundation
import FirebaseFirestore
import SwiftUI

struct ReviewSessionSummary: Codable, Hashable {
    var id: String = UUID().uuidString
    var userID: String?
    var startDate = Date()
    var completedDate = Date()
    var reviewMode: ReviewMode = .practice
    var targetCorrectCount: Int?
    var sessionTimeInSeconds: Int?
    var streakCount: Int?
    var correctScore: Int = 0
    var incorrectScore: Int = 0
    var flashcardReviewResults: [String: Bool] = [:] // Bool = isCorrect
    var numberOfFlashcards: Int = 0
    var numberOfDecks: Int = 0
}

extension ReviewSessionSummary: Firestorable {
    var timeStudied: TimeInterval {
        return completedDate.timeIntervalSince(startDate)
    }

    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        let keyPathMapping: [AnyKeyPath: String] = [
            \ReviewSessionSummary.id: "id",
            \ReviewSessionSummary.userID: "userID",
            \ReviewSessionSummary.startDate: "startDate",
            \ReviewSessionSummary.completedDate: "completedDate",
            \ReviewSessionSummary.reviewMode: "reviewMode",
            \ReviewSessionSummary.correctScore: "correctScore",
            \ReviewSessionSummary.incorrectScore: "incorrectScore",
            \ReviewSessionSummary.flashcardReviewResults: "flashcardReviewResults",
            \ReviewSessionSummary.numberOfFlashcards: "numberOfFlashcards",
            \ReviewSessionSummary.numberOfDecks: "numberOfDecks"
        ]

        return keyPathMapping[keyPath] ?? ""
    }
}
