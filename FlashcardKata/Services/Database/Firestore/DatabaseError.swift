//
//  DatabaseError.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that defines the different errors related to database operations.

import Foundation

enum DatabaseError: Error {
    case createError
    case fetchError
    case updateError
    case deleteError
    case authenticationError
    case unknownError

    var localizedDescription: String {
        switch self {
        case .createError:
            return "Failed to create item. Please try again."
        case .fetchError:
            return "Failed to fetch item. Please try again."
        case .updateError:
            return "Failed to update item. Please try again."
        case .deleteError:
            return "Failed to delete item. Please try again."
        case .authenticationError:
            return "Authentication failed. Please try again."
        case .unknownError:
            return "An unknown error occurred. Please try again."
        }
    }
}
