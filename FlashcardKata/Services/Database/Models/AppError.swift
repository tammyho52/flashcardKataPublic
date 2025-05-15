//
//  AppError.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum to represent various error states in the application.

import Foundation

/// Represents error states within the application.
enum AppError: Error {
    case networkError
    case userNotAuthenticated
    case userAccountError(String)
    case validationError(String)
    case permissionError
    case systemError
    
    /// A message describing the error.
    var message: String {
        switch self {
        case .networkError:
            return "Network error occurred. Please check your connection."
        case .userNotAuthenticated:
            return "User is not authenticated."
        case .userAccountError(let message):
            return message
        case .validationError(let message):
            return message
        case .permissionError:
            return "You do not have permission to perform this action."
        case .systemError:
            return "An unexpected error occurred. Please try again later."
        }
    }
}

extension AppError: Equatable {
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError, .networkError),
            (.userNotAuthenticated, .userNotAuthenticated),
            (.permissionError, .permissionError),
            (.systemError, .systemError):
            return true
        case (.userAccountError(let lhsMessage), .userAccountError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.validationError(let lhsMessage), .validationError(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}


