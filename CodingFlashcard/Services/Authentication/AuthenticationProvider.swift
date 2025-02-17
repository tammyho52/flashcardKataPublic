//
//  AuthProviderOption.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

// MARK: - AuthenticationProvider Enum
/// This enum represents the general authentication provider type with raw string values corresponding to the authentication service (e.g. email, Google, Apple).

enum AuthenticationProvider: String {
    case emailPassword = "password"
    case google = "google.com"
    case apple = "apple.com"
    case guest = "guest"
}

// MARK: - AuthProviderEnum
/// This enum is used for specific authentication actions that require associated values such as email and password for email sign in.
///
enum AuthProvider {
    case email(email: String, password: String)
    case google
    case apple
    case guest
}

