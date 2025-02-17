//
//  DeckNameLabel-MOCK.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

#if DEBUG
extension DeckNameLabel {
    static let sample = DeckNameLabel(id: UUID().uuidString, parentDeckID: UUID().uuidString, name: "Software Engineering", theme: .blue, isSubDeck: false)
}
#endif
