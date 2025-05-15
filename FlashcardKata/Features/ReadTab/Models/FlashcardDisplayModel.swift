//
//  FlashcardDisplayModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A model that represents the data required to display a flashcard.

import Foundation

/// A model representing the data required to display a flashcard.
struct FlashcardDisplayModel {
    let flashcard: Flashcard
    let deckNameLabel: DeckNameLabel // The label for the deck name associated with the flashcard.
}

extension FlashcardDisplayModel: Equatable {
    static func == (lhs: FlashcardDisplayModel, rhs: FlashcardDisplayModel) -> Bool {
        return lhs.flashcard.id == rhs.flashcard.id
    }
}
