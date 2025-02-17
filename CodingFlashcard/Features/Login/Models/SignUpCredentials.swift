//
//  SignUpCredentials.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

struct SignUpCredentials {
    var email: String = ""
    var password: String = ""
    var name: String = ""
    var agreedToLegal: Bool = false
    var authenticationProvider: String = AuthenticationProvider.emailPassword.rawValue
}
