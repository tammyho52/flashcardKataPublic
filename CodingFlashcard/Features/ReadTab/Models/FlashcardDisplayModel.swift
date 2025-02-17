//
//  FlashcardDisplayModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation

struct FlashcardDisplayModel: Equatable {
    let flashcard: Flashcard
    let deckNameLabel: DeckNameLabel
    
    static func == (lhs: FlashcardDisplayModel, rhs: FlashcardDisplayModel) -> Bool {
        return lhs.flashcard.id == rhs.flashcard.id
    }
}

