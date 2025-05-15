//
//  OrderDecksByParent.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to order decks by their parent deck ID and specified sort operator.

import Foundation

/// Orders decks by their parent deck ID and sort operator.
func orderDecksByParentDeckID<T: Comparable>(
    deckList: [Deck],
    orderBy keyPath: KeyPath<Deck, T>,
    sortOperator: @escaping (T, T) -> Bool
) -> [Deck] {
    var subdecksByParentDeckID: [String: [Deck]] = [:]
    var parentDecks: [Deck] = []

    // Separate decks into parent decks and subdecks
    for deck in deckList {
        if let parentDeckID = deck.parentDeckID {
            subdecksByParentDeckID[parentDeckID, default: []].append(deck)
        } else {
            parentDecks.append(deck)
        }
    }
    
    // Sort parent decks by the specified key path
    parentDecks.sort { sortOperator($0[keyPath: keyPath], $1[keyPath: keyPath]) }
    var orderedDecks: [Deck] = []

    // Append parent decks and their sorted subdecks to the ordered list
    for parentDeck in parentDecks {
        orderedDecks.append(parentDeck)

        if let subdecks = subdecksByParentDeckID[parentDeck.id] {
            orderedDecks.append(contentsOf: subdecks.sorted {
                sortOperator($0[keyPath: keyPath], $1[keyPath: keyPath])
            })
        }
    }

    return orderedDecks
}
