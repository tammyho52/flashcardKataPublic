//
//  AuthenticationViewState.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that represents the user's authentication state.

import Foundation

enum AuthenticationState: Equatable {
    case guestUser
    case signedIn
    case signedOut
}
