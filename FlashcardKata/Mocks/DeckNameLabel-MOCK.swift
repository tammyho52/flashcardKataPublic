//
//  DeckNameLabel-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for deck name label.

import Foundation

#if DEBUG
extension DeckNameLabel {
    static let sample = DeckNameLabel(
        id: UUID().uuidString,
        parentDeckID: UUID().uuidString,
        name: "Software Engineering",
        theme: .blue,
        isSubDeck: false
    )
}
#endif
