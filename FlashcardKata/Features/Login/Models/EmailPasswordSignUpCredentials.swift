//
//  EmailPasswordSignUpCredentials.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Store email and password for sign up.

import Foundation

struct EmailPasswordSignUpCredentials {
    var email: String = ""
    var password: String = ""
    var name: String = ""
    var agreedToLegal: Bool = false
    var authenticationProvider: String = AuthenticationProvider.emailPassword.rawValue
}
