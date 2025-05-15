//
//  FlashcardUpdate.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum to represent different types of updates that can be made to a flashcard.

import Foundation

enum FlashcardUpdate {
    case deckID(String)
    case frontText(String)
    case backText(String)
    case hint(String)
    case notes(String)
    case difficultyLevel(DifficultyLevel)
    case updatedDate(Date)
    case recentReviewedDate(Date)
    case correctReviewCount(Int)
    case incorrectReviewCount (Int)

    var key: String {
        switch self {
        case .deckID:
            return "deckID"
        case .frontText:
            return "frontText"
        case .backText:
            return "backText"
        case .hint:
            return "hint"
        case .notes:
            return "notes"
        case .difficultyLevel:
            return "difficultyLevel"
        case .updatedDate:
            return "updatedDate"
        case .recentReviewedDate:
            return "recentReviewedDate"
        case .correctReviewCount:
            return "correctReviewCount"
        case .incorrectReviewCount:
            return "incorrectReviewCount"
        }
    }
}


