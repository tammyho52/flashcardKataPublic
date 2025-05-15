//
//  Pluralize.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to handle the pluralization of specific content words based on a given count.

import Foundation

/// Function to pluralize content words based on the provided count.
func pluralizeByContentWord(word: ContentWord, count: Int) -> String {
    switch count {
    case 0:
        return "No \(word.plural)"
    case 1:
        return "1 \(word.singular)"
    default:
        return "\(count) \(word.plural)"
    }
}

/// Enum representing content words with their singular and plural forms.
enum ContentWord: String {
    case deck
    case subdeck
    case flashcard

    var singular: String {
        switch self {
        case .deck: return "deck"
        case .subdeck: return "subdeck"
        case .flashcard: return "flashcard"
        }
    }

    var plural: String {
        switch self {
        case .deck: return "decks"
        case .subdeck: return "subdecks"
        case .flashcard: return "flashcards"
        }
    }
}
