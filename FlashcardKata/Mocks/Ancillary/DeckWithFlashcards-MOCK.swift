//
//  DeckWithFlashcards-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for deck with flashcards.

import Foundation

#if DEBUG
extension DeckWithFlashcards {
    static let sample: DeckWithFlashcards = DeckWithFlashcards(
        deck: Deck.sampleDeck,
        flashcards: Flashcard.sampleFlashcardArray
    )
    static let sample2: DeckWithFlashcards = DeckWithFlashcards(
        deck: Deck.sampleDeck,
        flashcards: Flashcard.sampleFlashcardArray
    )

    static let sampleArray: [DeckWithFlashcards] = [sample, sample2]
}
#endif
