//
//  CardSort.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

enum CardSort: String, CaseIterable, Identifiable {
    case shuffle
    case lastUpdated
    case byDeck
    
    
    var id: Self { self }
    var rawValueCapitalized: String {
        switch self {
        case .shuffle:
            "Shuffle"
        case .lastUpdated:
            "Last Updated"
        case .byDeck:
            "By Deck"
        }
    }
}
