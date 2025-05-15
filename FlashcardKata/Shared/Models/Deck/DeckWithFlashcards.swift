//
//  DeckWithFlashcards.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure representing a deck and its associated flashcards.

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
