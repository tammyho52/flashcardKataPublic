//
//  Deck.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Model to represent a deck of flashcards.

import SwiftUI
import FirebaseFirestore

struct Deck: Identifiable, Hashable, Equatable, Codable, UUIDIdentifiable {
    var id: String = UUID().uuidString
    var userID: String?
    var name: String = ""
    var theme: Theme = .blue
    var parentDeckID: String?
    var subdeckIDs: [String] = []
    var flashcardIDs: [String] = []
    var reviewedFlashcardIDs: [String] = [] 
    var lastReviewedDate: Date?
    var createdDate: Date = Date()
    var updatedDate: Date = Date()

    var flashcardCount: Int { flashcardIDs.count }
    var subdeckCount: Int { subdeckIDs.count }
    var isSubdeck: Bool { parentDeckID == nil ? false : true }
    var deckReviewStatistics: DeckReviewStatistics {
        DeckReviewStatistics(deck: self)
    }
}

extension Deck: Firestorable {
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        let fieldNames: [AnyKeyPath: String] = [
            \Deck.id: "id",
            \Deck.userID: "userID",
            \Deck.name: "name",
            \Deck.theme: "theme",
            \Deck.parentDeckID: "parentDeckID",
            \Deck.subdeckIDs: "subdeckIDs",
            \Deck.flashcardIDs: "flashcardIDs",
            \Deck.reviewedFlashcardIDs: "reviewedFlashcardIDs",
            \Deck.lastReviewedDate: "lastReviewedDate",
            \Deck.createdDate: "createdDate",
            \Deck.updatedDate: "updatedDate"
        ]

        return fieldNames[keyPath] ?? ""
    }
}

extension Deck {
    var deckNameLabel: DeckNameLabel {
        return DeckNameLabel(
            id: self.id,
            parentDeckID: self.parentDeckID,
            name: self.name,
            theme: self.theme,
            isSubDeck: !self.subdeckIDs.isEmpty
        )
    }
}
