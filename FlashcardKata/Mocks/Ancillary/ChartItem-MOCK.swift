//
//  ChartItem-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for chart item.

import Foundation

#if DEBUG
extension ChartItem {
    static let sample = ChartItem(
        deck: Deck.sampleSubdeck,
        flashcardReviewResults: ["flashcard9": true, "flashcard10": false]
    )
    
    static let sampleArray = [
        ChartItem(
            deck: Deck.sampleDeckArray[0],
            flashcardReviewResults: ["flashcard1": true, "flashcard2": false]
        ),
        ChartItem(
            deck: Deck.sampleDeckArray[1],
            flashcardReviewResults: ["flashcard3": true, "flashcard4": false]
        ),
        ChartItem(
            deck: Deck.sampleDeckArray[2],
            flashcardReviewResults: ["flashcard5": true, "flashcard6": false, "flashcard7": true, "flashcard8": true]
        )
    ]
}
#endif
