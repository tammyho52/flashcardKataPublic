//
//  Pluralize.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

func pluralize(word: ContentWord, count: Int) -> String {
    switch count {
    case 0:
        return "No \(word.plural)"
    case 1:
        return "1 \(word.singular)"
    default:
        return "\(count) \(word.plural)"
    }
}

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
