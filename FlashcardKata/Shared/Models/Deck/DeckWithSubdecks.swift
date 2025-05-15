//
//  DeckWithSubdecks.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure representing a parent deck and its associated subdecks.

import Foundation

struct DeckWithSubdecks {
    var parentDeck: Deck
    var subdecks: [Deck]
}

extension DeckWithSubdecks: Identifiable {
    var id: String {
        return parentDeck.id
    }
}
