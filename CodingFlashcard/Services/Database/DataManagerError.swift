//
//  DataManagerError.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

enum DataManagerError: Error {
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
