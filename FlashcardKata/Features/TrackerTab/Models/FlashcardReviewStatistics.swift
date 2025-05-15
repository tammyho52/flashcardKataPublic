//
//  FlashcardReviewStatistics.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A model that represents the review statistics of a flashcard.

import SwiftUI

/// A model that represents the review statistics of a flashcard, including correct and incorrect information.
struct FlashcardReviewStatistics: Hashable {
    let id: String
    let frontText: String
    let correctReviewCount: Int
    let incorrectReviewCount: Int
    
    var totalReviewCount: Int {
        return correctReviewCount + incorrectReviewCount
    }
    
    var correctPercentage: Double {
        guard totalReviewCount > 0 else { return 0 }
        return Double(correctReviewCount) / Double(totalReviewCount) * 100
    }
    
    var incorrectPercentage: Double {
        guard totalReviewCount > 0 else { return 0 }
        return Double(incorrectReviewCount) / Double(totalReviewCount) * 100
    }
}

extension FlashcardReviewStatistics {
    /// Initializes a `FlashcardReviewStatistics` instance from a `Flashcard`.
    init(flashcard: Flashcard) {
        self.id = flashcard.id
        self.frontText = flashcard.frontText
        self.correctReviewCount = flashcard.correctReviewCount
        self.incorrectReviewCount = flashcard.incorrectReviewCount
    }
}
