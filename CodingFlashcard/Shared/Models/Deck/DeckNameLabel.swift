//
//  DeckNameLabel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct DeckNameLabel: Hashable {
    var id: String
    var parentDeckID: String?
    var name: String
    var theme: Theme
    var isSubDeck: Bool
}
