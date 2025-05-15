//
//  OrderFlashcardsByUpdatedDate.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to order flashcards by last updated date.

import Foundation

/// Orders an array of flashcards by their last updated date in descending order.
func orderFlashcardsByUpdatedDate(flashcards: [Flashcard]) -> [Flashcard] {
    return flashcards.sorted(by: { $0.updatedDate > $1.updatedDate })
}
