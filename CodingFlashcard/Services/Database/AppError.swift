//
//  AppError.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

enum AppError: Error {
    case networkError
    case serverError(code: Int)
    case unauthorized
    case encodingError
    case decodingError
    case databaseError(reason: String)
    case invalidInput(message: String)
    case unknownError
    
    var message: String {
        switch self {
        case .networkError:
            return "Unable to process request. Please check your network."
        case .serverError(_):
            return "Server error. Please try again later."
        case .unauthorized:
            return "You are not authorized. Please log in again."
        case .encodingError, .decodingError:
            return "There was an error processing your data. Please contact support."
        case .databaseError(_):
            return "Database error. Please try again."
        case .invalidInput(let inputType):
            return "Invalid input: \(inputType). Please update and try again."
        case .unknownError:
            return "An unknown error occurred. Please contact support."
        }
    }
}
