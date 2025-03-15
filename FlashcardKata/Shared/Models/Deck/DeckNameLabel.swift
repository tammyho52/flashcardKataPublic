//
//  DeckNameLabel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Model that represents a simplified label for a deck.

import SwiftUI

struct DeckNameLabel: Hashable {
    var id: String
    var parentDeckID: String?
    var name: String
    var theme: Theme
    var isSubDeck: Bool
}
