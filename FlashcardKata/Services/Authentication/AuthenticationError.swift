//
//  AuthenticationError.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that represents the errors during the authentication process.

import Foundation

enum AuthenticationError: Error {
    case userNotAuthenticated
    case signOutFailed
    case signInFailed
    case unknownAuthenticationMode
    case missingCredentials
}
