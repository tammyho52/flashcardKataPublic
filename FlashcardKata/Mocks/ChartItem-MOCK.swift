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
    static let sampleArray = [
        ChartItem(
            deck: Deck.sampleDeckArray[0],
            flashcardsReviewed: ["flashcard1": true, "flashcard2": false]
        ),
        ChartItem(
            deck: Deck.sampleDeckArray[1],
            flashcardsReviewed: ["flashcard3": true, "flashcard4": false]
        ),
        ChartItem(
            deck: Deck.sampleDeckArray[2],
            flashcardsReviewed: ["flashcard5": true, "flashcard6": false, "flashcard7": true, "flashcard8": true]
        )
    ]
}
#endif
