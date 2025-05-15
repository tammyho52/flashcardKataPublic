//
//  SortFlashcardDisplayModels.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to sort flashcard display models based on the selected card sort option.

import Foundation

/// Enum representing the sorting options for flashcard display models.
func sortFlashcardDisplayModels(displayCardSort cardSort: CardSort, flashcardDisplayModels: [FlashcardDisplayModel]) -> [FlashcardDisplayModel] {
    switch cardSort {
    case .lastUpdated:
        // Sort by last updated date, descending
        flashcardDisplayModels.sorted(by: { $0.flashcard.updatedDate > $1.flashcard.updatedDate })
    case .byDeck:
        // Sort by deck name and then by last updated date, descending
        flashcardDisplayModels.sorted(by: {
            ($0.deckNameLabel.id, $0.flashcard.updatedDate) > ($1.deckNameLabel.id, $1.flashcard.updatedDate)
        })
    case .shuffle:
        // Shuffle the flashcard display models
        flashcardDisplayModels.shuffled()
    }
}
