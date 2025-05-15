//
//  MockAnyAuthenticationManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Mock implementation of AnyAuthenticationManager for testing purposes.

import Foundation

#if DEBUG
extension AnyAuthenticationManager {
    static let sample = AnyAuthenticationManager(
        authenticationManager: FirebaseAuthenticationManager()
    )
}
#endif
