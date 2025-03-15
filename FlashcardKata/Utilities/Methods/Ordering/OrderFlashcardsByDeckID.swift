//
//  OrderFlashcardsByDeckID.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to order flashcards by last updated date.

import Foundation

func orderFlashcardsByUpdatedDate(flashcards: [Flashcard]) -> [Flashcard] {
    return flashcards.sorted(by: { $0.updatedDate > $1.updatedDate })
}
