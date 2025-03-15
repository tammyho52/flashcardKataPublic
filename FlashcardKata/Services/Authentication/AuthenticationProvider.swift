//
//  AuthProviderOption.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
// Enum that represents the authentication providers (e.g. email, Google, Apple).

import Foundation

enum AuthenticationProvider: String {
    case emailPassword = "password"
    case google = "google.com"
    case apple = "apple.com"
    case guest = "guest"
}

enum AuthProvider {
    case email(email: String, password: String)
    case google
    case apple
    case guest
}
