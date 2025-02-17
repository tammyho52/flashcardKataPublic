//
//  SearchResultData-MOCK.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

#if DEBUG
extension SearchResult {
    static var mockFlashcard: SearchResult {
        return SearchResult(flashcard: Flashcard.sampleFlashcard, deckName: "Deck Name", theme: .blue)
    }

    static var mockDeck: SearchResult {
        return SearchResult(deck: Deck.sampleDeck)
    }
    
    static var mockSubdeck: SearchResult {
        return SearchResult(deck: Deck.sampleSubdeck)
    }

    static var longMockDeck: SearchResult {
        return SearchResult(searchResultType: .deck, id: UUID().uuidString, title: "This is a very long title to see what would happen if it spills to multiple lines", subTitle: "Deck", theme: .blue)
    }
}
#endif
