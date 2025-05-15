//
//  GoogleSignInResult.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  The result of a Google Sign-In operation.

import Foundation
import FirebaseAuth

struct GoogleSignInResult {
    let credential: AuthCredential
    let name: String?
    let email: String?
}
