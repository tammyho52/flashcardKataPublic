//
//  DatabaseManagerError.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum representing errors when interacting with the database manager.

import Foundation

enum DatabaseManagerError: Error {
    case deckFetchError(error: Error)
    case deckSaveError(error: Error)
    case deckEditError(error: Error)
    case deckDeleteError(error: Error)
    case flashcardFetchError(error: Error)
    case flashcardSaveError(error: Error)
    case flashcardEditError(error: Error)
    case flashcardDeleteError(error: Error)
    case userIDError
}
