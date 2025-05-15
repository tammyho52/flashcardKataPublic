//
//  ReviewSessionSummary-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for review session summary.

import Foundation

#if DEBUG
extension ReviewSessionSummary {
    static let sample = sampleArray[0]
    static let sampleArray: [ReviewSessionSummary] = [
        ReviewSessionSummary(
            startDate: Date().addingTimeInterval(-600),
            correctScore: 10,
            incorrectScore: 10,
            flashcardReviewResults: [
                Flashcard.sampleFlashcardArray[0].id: true,
                Flashcard.sampleFlashcardArray[1].id: false
            ],
            numberOfFlashcards: 20,
            numberOfDecks: 5
        ),
        ReviewSessionSummary(
            startDate: Date().addingTimeInterval(-600),
            correctScore: 10,
            incorrectScore: 10,
            flashcardReviewResults: [
                Flashcard.sampleFlashcardArray[21].id: true,
                Flashcard.sampleFlashcardArray[4].id: false,
                Flashcard.sampleFlashcardArray[5].id: true
            ],
            numberOfFlashcards: 20,
            numberOfDecks: 5
        ),
        ReviewSessionSummary(
            startDate: Date().addingTimeInterval(-600),
            correctScore: 10,
            incorrectScore: 10,
            flashcardReviewResults: [
                Flashcard.sampleFlashcardArray[10].id: true,
                Flashcard.sampleFlashcardArray[11].id: false,
                Flashcard.sampleFlashcardArray[12].id: true
            ],
            numberOfFlashcards: 20,
            numberOfDecks: 5
        )
    ]
}
#endif
