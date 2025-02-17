//
//  DeckWithFlashcards.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

struct DeckWithFlashcards: Hashable {
    var deck: Deck
    var flashcards: [Flashcard]
}

extension DeckWithFlashcards: Identifiable {
    var id: String {
        return deck.id
    }
}
