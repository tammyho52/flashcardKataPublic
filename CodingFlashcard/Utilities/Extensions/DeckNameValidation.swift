//
//  DeckNameValidation.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

protocol DeckNameValidatable {
    var deckName: String { get }
}

extension DeckNameValidatable {
    var isInvalidDeckName: Bool {
        deckName.isEmpty
    }
}
