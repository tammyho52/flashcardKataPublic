//
//  OrderFlashcardsByDeckID.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation


func orderFlashcardsByUpdatedDate(flashcards: [Flashcard]) -> [Flashcard] {
    return flashcards.sorted(by: { $0.updatedDate > $1.updatedDate })
}
