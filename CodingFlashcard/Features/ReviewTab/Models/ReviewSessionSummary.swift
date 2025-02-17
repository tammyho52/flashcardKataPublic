//
//  ReviewSessionSummary.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Charts

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
    var flashcardReviewResults: [String: Bool] = [:]
    var numberOfFlashcards: Int = 0
    var numberOfDecks: Int = 0
}

extension ReviewSessionSummary: Firestorable {
    var timeStudied: TimeInterval {
        return completedDate.timeIntervalSince(startDate)
    }
    
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        switch keyPath {
        case \ReviewSessionSummary.id:
            return "id"
        case \ReviewSessionSummary.userID:
            return "userID"
        case \ReviewSessionSummary.startDate:
            return "startDate"
        case \ReviewSessionSummary.completedDate:
            return "completedDate"
        case \ReviewSessionSummary.reviewMode:
            return "reviewMode"
        case \ReviewSessionSummary.correctScore:
            return "correctScore"
        case \ReviewSessionSummary.incorrectScore:
            return "incorrectScore"
        case \ReviewSessionSummary.flashcardReviewResults:
            return "flashcardReviewResults"
        case \ReviewSessionSummary.numberOfFlashcards:
            return "numberOfFlashcards"
        case \ReviewSessionSummary.numberOfDecks:
            return "numberOfDecks"
        default:
            return ""
        }
    }
}
