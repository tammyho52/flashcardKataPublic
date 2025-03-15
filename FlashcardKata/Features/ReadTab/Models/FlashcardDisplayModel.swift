//
//  FlashcardDisplayModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model that represents the data required to load a flashcard display.

import Foundation

struct FlashcardDisplayModel: Equatable {
    let flashcard: Flashcard
    let deckNameLabel: DeckNameLabel

    static func == (lhs: FlashcardDisplayModel, rhs: FlashcardDisplayModel) -> Bool {
        return lhs.flashcard.id == rhs.flashcard.id
    }
}
