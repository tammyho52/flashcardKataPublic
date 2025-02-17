//
//  Deck.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI
import FirebaseFirestore

// Deck Model
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
        switch keyPath {
        case \Deck.id:
            return "id"
        case \Deck.userID:
            return "userID"
        case \Deck.name:
            return "name"
        case \Deck.theme:
            return "theme"
        case \Deck.parentDeckID:
            return "parentDeckID"
        case \Deck.subdeckIDs:
            return "subdeckIDs"
        case \Deck.flashcardIDs:
            return "flashcardIDs"
        case \Deck.lastReviewedDate:
            return "lastReviewedDate"
        case \Deck.createdDate:
            return "createdDate"
        case \Deck.updatedDate:
            return "updatedDate"
        default:
            return ""
        }
    }
}

extension Deck {
    var combinedDeckID: CombinedDeckID {
        CombinedDeckID(deckID: id, parentDeckID: parentDeckID)
    }
    
    var deckNameLabel: DeckNameLabel {
        return DeckNameLabel(id: self.id, parentDeckID: self.parentDeckID, name: self.name, theme: self.theme, isSubDeck: !self.subdeckIDs.isEmpty)
    }
}

//DeckID
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
