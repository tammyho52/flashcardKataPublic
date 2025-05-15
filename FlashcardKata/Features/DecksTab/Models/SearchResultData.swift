//
//  SearchResultData.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A data model representing a search result item. This model is used to encapsulate
//  information about decks, subdecks, and flashcards in a unified format for search functionality.

import Foundation

/// A model representing a search result item.
struct SearchResult: Identifiable {
    var searchResultType: SearchResultType
    var id: String
    var title: String // The main title of the search result (e.g., deck name or flashcard front text).
    var subTitle: String  // A subtitle providing additional context (e.g., "Deck", "Subdeck", or the parent deck name).
    var theme: Theme // The theme associated with the search result, used for styling.
}

// MARK: - Initializers
extension SearchResult {
    /// Initializer for creating a search result from a deck.
    init(deck: Deck) {
        self.searchResultType = deck.isSubdeck ? .subdeck : .deck
        self.id = deck.id
        self.title = deck.name
        self.subTitle = deck.isSubdeck ? "Subdeck" : "Deck" // Indicates whether it's a subdeck or a parent deck.
        self.theme = deck.theme
    }
    
    /// Initializer for creating a search result from a flashcard.
    init(flashcard: Flashcard, deckName: String, theme: Theme) {
        self.searchResultType = .flashcard
        self.id = flashcard.id
        self.title = flashcard.frontText
        self.subTitle = deckName
        self.theme = theme
    }
}

// Defines the different types of search results.
enum SearchResultType {
    case deck
    case subdeck
    case flashcard
}
