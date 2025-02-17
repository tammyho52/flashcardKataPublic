//
//  AuthenticationError.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

enum AuthenticationError: Error {
    case userNotAuthenticated
    case signOutFailed
    case signInFailed
    case unknownAuthenticationMode
    case missingCredentials
}
