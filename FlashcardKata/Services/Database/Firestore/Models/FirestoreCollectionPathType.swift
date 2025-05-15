//
//  FirestoreCollectionPath.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that defines the Firestore collection paths for different data types in the app.

import Foundation

enum FirestoreCollectionPathType {
    case deck
    case flashcard
    case userProfile
    case reviewSessionSummary
    case custom(String)

    var path: String {
        switch self {
        case .deck:
            return "deck"
        case .flashcard:
            return "flashcard"
        case .userProfile:
            return "userProfile"
        case .reviewSessionSummary:
            return "reviewSessionSummary"
        case .custom(let customPath):
            return customPath
        }
    }
}
