//
//  Deck-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generate mock data for decks and subdecks.

import Foundation

#if DEBUG
extension Deck {
    static let sampleDeck = MockData.deckData[0]
    static let sampleDeckArray = MockData.deckData

    static let sampleSubdeck = MockData.subdeckData[0]
    static let sampleSubdeckArray = MockData.subdeckData

    static let allSampleDecks = sampleDeckArray + sampleSubdeckArray

    static let sampleCombinedDeckSubDecks: [(Deck, [Deck])] = MockData.sampleCombinedDeckSubDecks
    static let sampleCombinedDeckIDSubdeckArray: [String: [Deck]] = MockData.sampleCombinedDeckIDSubdeckArray
}
#endif
