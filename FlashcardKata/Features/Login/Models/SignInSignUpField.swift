//
//  SignInSignUpField.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum representing the different input fields used in email/password sign-in and sign-up forms.

import Foundation

/// Represents the individual form fields used across sign in and sign up flows.
enum SignInSignUpField {
    /// The user's display name (sign up only)
    case name
    /// The user's email address (used in both sign in and sign up)
    case email
    /// The user's password (used in both sign in and sign up)
    case password
    /// The user's password confirmation (sign up only)
    case confirmPassword
    /// Legal agreement acknowledgement (sign up only)
    case agreedToLegal

    /// Description for each field, typically used in text field labels.
    var description: String {
        switch self {
        case .name:
            return "Name"
        case .email:
            return "Email"
        case .password:
            return "Password"
        case .confirmPassword:
            return "Confirm Password"
        case .agreedToLegal:
            return "Legal Agreements"
        }
    }

    /// Symbol identifier for each field, used for the inline icons in textfields.
    var symbol: String {
        switch self {
        case .name:
            return ContentConstants.Symbols.name
        case .email:
            return ContentConstants.Symbols.email
        case .password:
            return ContentConstants.Symbols.password
        case .confirmPassword:
            return ContentConstants.Symbols.confirmPassword
        case .agreedToLegal:
            return "" // No icon needed for the legal agreement checkbox
        }
    }
}
