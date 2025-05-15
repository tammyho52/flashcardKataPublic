//
//  SearchResultData-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for search results by data type (deck, subdeck, flashcard).

import Foundation

#if DEBUG
extension SearchResult {
    static var sampleFlashcard: SearchResult {
        return SearchResult(flashcard: Flashcard.sampleFlashcard, deckName: "Deck Name", theme: .blue)
    }

    static var sampleDeck: SearchResult {
        return SearchResult(deck: Deck.sampleDeck)
    }

    static var sampleSubdeck: SearchResult {
        return SearchResult(deck: Deck.sampleSubdeck)
    }

    static var longSampleDeck: SearchResult {
        return SearchResult(
            searchResultType: .deck,
            id: UUID().uuidString,
            title: "This is a very long title to see what would happen if it spills to multiple lines",
            subTitle: "Deck",
            theme: .blue
        )
    }
}
#endif
