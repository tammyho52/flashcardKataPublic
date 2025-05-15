//
//  DeckReviewStatistics.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This model represents the review statistics for a deck.

import SwiftUI

/// A model representing the review statistics for a deck, including progress percentage, card count, and deck-specific properties.
struct DeckReviewStatistics: Hashable {
    var id: String
    var deckName: String
    var totalCards: Int
    var cardsReviewed: Int
    var deckColor: Color
    
    var progressPercentage: Double {
        guard totalCards > 0 else {
            return 0
        }
        return Double(cardsReviewed) / Double(totalCards)
    }
    
    var progressPercentageString: String {
        let percentage = progressPercentage * 100
        return String(format: "%.1f%%", percentage)
    }
    
    var reviewText: String {
        "\(cardsReviewed)/\(totalCards) Cards"
    }
}

extension DeckReviewStatistics {
    /// Initializes a `DeckReviewStatistics` instance with the given `Deck`.
    init(deck: Deck) {
        self.id = deck.id
        self.deckName = deck.name
        self.totalCards = deck.flashcardIDs.count
        self.cardsReviewed = deck.reviewedFlashcardIDs.count
        self.deckColor = deck.isSubdeck ? deck.theme.secondaryColor : deck.theme.primaryColor
    }
}
