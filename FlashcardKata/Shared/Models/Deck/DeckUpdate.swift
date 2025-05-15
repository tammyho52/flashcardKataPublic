//
//  DeckUpdate.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum representing different types of updates that can be made to a deck.

import Foundation

enum DeckUpdate {
    case name(String)
    case theme(Theme)
    case parentDeckID(String)
    case subdeckIDs(IDUpdate)
    case flashcardIDs(IDUpdate)
    case reviewedFlashcardIDs(IDUpdate)
    case lastReviewedDate(Date)
    case updatedDate(Date)

    var key: String {
        switch self {
        case .name:
            return "name"
        case .theme:
            return "theme"
        case .parentDeckID:
            return "parentDeckID"
        case .subdeckIDs:
            return "subdeckIDs"
        case .flashcardIDs:
            return "flashcardIDs"
        case .reviewedFlashcardIDs:
            return "reviewedFlashcardIDs"
        case .lastReviewedDate:
            return "lastReviewedDate"
        case .updatedDate:
            return "updatedDate"
        }
    }
}
