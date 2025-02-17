//
//  DeckWithFlashcards-MOCK.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

#if DEBUG
extension DeckWithFlashcards {
    static let sample: DeckWithFlashcards = DeckWithFlashcards(deck: Deck.sampleDeck, flashcards: Flashcard.sampleFlashcardArray)
    static let sample2: DeckWithFlashcards = DeckWithFlashcards(deck: Deck.sampleDeck, flashcards: Flashcard.sampleFlashcardArray)
    
    static let sampleArray: [DeckWithFlashcards] = [sample, sample2]
}
#endif
