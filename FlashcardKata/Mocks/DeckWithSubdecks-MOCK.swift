//
//  DeckWithSubdecks-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for deck with subdecks.

import Foundation

#if DEBUG
extension DeckWithSubdecks {
    static let sample: DeckWithSubdecks = DeckWithSubdecks(
        parentDeck: Deck.sampleDeckArray[0],
        subdecks: [Deck.sampleSubdeckArray[0], Deck.sampleSubdeckArray[1], Deck.sampleSubdeckArray[2]]
    )
    static let sample2: DeckWithSubdecks = DeckWithSubdecks(
        parentDeck: Deck.sampleDeckArray[1],
        subdecks: [Deck.sampleSubdeckArray[3], Deck.sampleSubdeckArray[4]]
    )
    static let sampleArray: [DeckWithSubdecks] = [sample, sample2]
}
#endif
