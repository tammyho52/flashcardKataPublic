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
    var lastReviewedDate: Date?
    var createdDate: Date = Date()
    var updatedDate: Date = Date()

    var flashcardCount: Int { flashcardIDs.count }
    var subdeckCount: Int { subdeckIDs.count }
    var isSubdeck: Bool { parentDeckID == nil ? false : true }
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
            \Deck.lastReviewedDate: "lastReviewedDate",
            \Deck.createdDate: "createdDate",
            \Deck.updatedDate: "updatedDate"
        ]

        return fieldNames[keyPath] ?? ""
    }
}

extension Deck {
    var combinedDeckID: CombinedDeckID {
        CombinedDeckID(deckID: id, parentDeckID: parentDeckID)
    }

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

struct CombinedDeckID {
    var deckID: String
    var parentDeckID: String?
}

extension CombinedDeckID: Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(deckID)
        hasher.combine(parentDeckID)
    }

    static func == (lhs: CombinedDeckID, rhs: CombinedDeckID) -> Bool {
        return lhs.deckID == rhs.deckID && lhs.parentDeckID == rhs.parentDeckID
    }
}
