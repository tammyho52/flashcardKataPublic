//
//  Flashcard.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
}

extension Flashcard: UUIDIdentifiable {
    var name: String { return frontText }
}

extension Flashcard: Firestorable {
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        switch keyPath {
        case \Flashcard.id:
            return "id"
        case \Flashcard.userID:
            return "userID"
        case \Flashcard.deckID:
            return "deckID"
        case \Flashcard.frontText:
            return "frontText"
        case \Flashcard.backText:
            return "backText"
        case \Flashcard.hint:
            return "hint"
        case \Flashcard.notes:
            return "notes"
        case \Flashcard.difficultyLevel:
            return "difficultyLevel"
        case \Flashcard.createdDate:
            return "createdDate"
        case \Flashcard.updatedDate:
            return "updatedDate"
        case \Flashcard.recentReviewedDate:
            return "recentReviewedDate"
        default:
            return ""
        }
    }
}
