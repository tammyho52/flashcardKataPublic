//
//  FirestoreCollectionPath.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that defines the Firestore collection paths for different data types in the app.

import Foundation

enum FirestoreCollectionPath: String {
    case deck
    case flashcard
    case userProfile
    case reviewSessionSummary

    var path: String {
        self.rawValue
    }
}
