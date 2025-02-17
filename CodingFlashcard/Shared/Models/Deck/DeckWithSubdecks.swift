//
//  DeckWithSubdecks.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

struct DeckWithSubdecks {
    let parentDeck: Deck
    var subdecks: [Deck]
}

extension DeckWithSubdecks: Identifiable {
    var id: String {
        return parentDeck.id
    }
}
