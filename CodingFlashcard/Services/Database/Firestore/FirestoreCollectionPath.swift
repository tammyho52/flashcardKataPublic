//
//  FirestoreCollectionPath.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

enum FirestoreCollectionPath: String {
    case deck = "deck"
    case flashcard = "flashcard"
    case userProfile = "userProfile"
    case reviewSessionSummary = "reviewSessionSummary"
    
    var path: String {
        self.rawValue
    }
}
