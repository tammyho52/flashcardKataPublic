//
//  FlashcardWithDeckNameLabel -MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for flashcard display model.

import Foundation

#if DEBUG
extension FlashcardDisplayModel {
    static let sample =
        FlashcardDisplayModel(
            flashcard: Flashcard.sampleFlashcardArray[0],
            deckNameLabel: Deck.sampleDeckArray[0].deckNameLabel
        )

    static let sampleArray = [
        FlashcardDisplayModel(
            flashcard: Flashcard.sampleFlashcardArray[0],
            deckNameLabel: Deck.sampleDeckArray[0].deckNameLabel
        ),
        FlashcardDisplayModel(
            flashcard: Flashcard.sampleFlashcardArray[1],
            deckNameLabel: Deck.sampleDeckArray[1].deckNameLabel
        )
    ]
}
#endif
