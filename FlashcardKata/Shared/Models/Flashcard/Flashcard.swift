//
//  Flashcard.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Model to represent a flashcard.

import SwiftUI

// Flashcard Model
struct Flashcard: Identifiable, Equatable, Hashable, Codable {
    var id: String = UUID().uuidString
    var userID: String?
    var deckID: String
    var frontText: String = ""
    var backText: String = ""
    var hint: String = ""
    var notes: String = ""
    var difficultyLevel: DifficultyLevel = .medium
    var createdDate: Date = Date()
    var updatedDate: Date = Date()
    var recentReviewedDate: Date?
    var correctReviewCount: Int = 0
    var incorrectReviewCount: Int = 0
}

extension Flashcard: UUIDIdentifiable {
    var name: String { return frontText }
}

extension Flashcard: Firestorable {
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        let fieldNames: [AnyKeyPath: String] = [
            \Flashcard.id: "id",
            \Flashcard.userID: "userID",
            \Flashcard.deckID: "deckID",
            \Flashcard.frontText: "frontText",
            \Flashcard.backText: "backText",
            \Flashcard.hint: "hint",
            \Flashcard.notes: "notes",
            \Flashcard.difficultyLevel: "difficultyLevel",
            \Flashcard.createdDate: "createdDate",
            \Flashcard.updatedDate: "updatedDate",
            \Flashcard.recentReviewedDate: "recentReviewedDate",
            \Flashcard.correctReviewCount: "correctReviewCount",
            \Flashcard.incorrectReviewCount: "incorrectReviewCount"
        ]
        return fieldNames[keyPath] ?? ""
    }
}
