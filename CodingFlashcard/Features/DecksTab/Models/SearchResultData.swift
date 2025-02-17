//
//  SearchResultData.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation

struct SearchResult: Identifiable {
    var searchResultType: SearchResultType
    var id: String
    var title: String
    var subTitle: String
    var theme: Theme
}

extension SearchResult {
    init(deck: Deck) {
        self.searchResultType = deck.isSubdeck ? .subdeck : .deck
        self.id = deck.id
        self.title = deck.name
        self.subTitle = deck.isSubdeck ? "Subdeck" : "Deck"
        self.theme = deck.theme
    }
    
    init(flashcard: Flashcard, deckName: String, theme: Theme) {
        self.searchResultType = .flashcard
        self.id = flashcard.id
        self.title = flashcard.frontText
        self.subTitle = deckName
        self.theme = theme
    }
}

enum SearchResultType {
    case deck
    case subdeck
    case flashcard
}

enum SearchResultDataError: Error, LocalizedError {
    case invalidQuery
    
    var errorDescription: String? {
        switch self {
        case .invalidQuery:
            return "Invalid query - please try a different search."
        }
    }
}
