//
//  FlashcardReviewStatistics-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Mock data for FlashcardReviewStatistics.

import Foundation

#if DEBUG
extension FlashcardReviewStatistics {
    static let sample: FlashcardReviewStatistics = FlashcardReviewStatistics(flashcard: Flashcard.sampleFlashcard)
    static let sampleArray: [FlashcardReviewStatistics] = Flashcard.sampleFlashcardArray.map {
        FlashcardReviewStatistics(flashcard: $0)
    }
}

#endif
