//
//  SignInSignUpField.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

enum SignInSignUpField {
    case name
    case email
    case password
    case confirmPassword // Only for sign up
    case agreedToLegal // Only for sign up
    
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
            return " Agreed to Legal"
        }
    }
    
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
            return "" // Not needed
        }
    }
}
