//
//  EmailPasswordSignUpCredentials.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Model for storing user credentials to sign up with email/password.

import Foundation

/// A data structure that encapsulates the credentials required for signing up a user with email and password.
struct EmailPasswordSignUpCredentials {
    var email: String = ""
    var password: String = ""
    var name: String = ""
    var agreedToLegal: Bool = false
    var authenticationProvider: String = AuthenticationProvider.emailPassword.rawValue // Default to email/password
}
