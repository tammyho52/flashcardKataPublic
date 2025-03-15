//
//  ValidationHelper.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility structure that provides common validation checks for form fields.

import Foundation

struct ValidationHelper {

    static func isFieldEmpty(_ value: String, for fieldName: SignInSignUpField) -> String? {
        return value.isEmpty ? "\(fieldName.description) is required" : nil
    }

    static func isFieldTrue(_ condition: Bool, for fieldName: SignInSignUpField) -> String? {
        return condition == false ? "Please agree to the \(fieldName.description) to proceed." : nil
    }
}
