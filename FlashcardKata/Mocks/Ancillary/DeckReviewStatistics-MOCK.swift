//
//  DeckReviewStatistics-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Mock data for DeckReviewStatistics.

import Foundation

#if DEBUG
extension DeckReviewStatistics {
    static let sampleArray = Deck.sampleDeckArray.map { DeckReviewStatistics(deck: $0) }
    static let sampleDeckWithSubdecksReviewStatistics = Deck.sampleParentDeckWithSubDecksArray.reduce(into: [DeckReviewStatistics: [DeckReviewStatistics]]()) { result, pair in
        let (deck, subdecks) = pair
        let deckReviewStatistics = DeckReviewStatistics(deck: deck)
        let subdeckReviewStatistics = subdecks.map { DeckReviewStatistics(deck: $0) }
        result[deckReviewStatistics] = subdeckReviewStatistics
    }
}
#endif
