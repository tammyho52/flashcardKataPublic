//
//  OrderDecksByParent.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

func orderDecksByParentDeckID<T: Comparable>(deckList: [Deck], orderBy keyPath: KeyPath<Deck, T>, sortOperator: @escaping (T, T) -> Bool) -> [Deck] {
    var subdecksByParentDeckID: [String: [Deck]] = [:]
    var parentDecks: [Deck] = []

    for deck in deckList {
        if let parentDeckID = deck.parentDeckID {
            subdecksByParentDeckID[parentDeckID, default: []].append(deck)
        } else {
            parentDecks.append(deck)
        }
    }

    parentDecks.sort { sortOperator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    var orderedDecks: [Deck] = []
    
    for parentDeck in parentDecks {
        orderedDecks.append(parentDeck)
        
        if let subdecks = subdecksByParentDeckID[parentDeck.id] {
            orderedDecks.append(contentsOf: subdecks.sorted { sortOperator($0[keyPath: keyPath], $1[keyPath: keyPath]) })
        }
    }

    return orderedDecks
}
