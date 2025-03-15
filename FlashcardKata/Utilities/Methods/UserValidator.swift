//
//  UserValidator.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure containing utility methods to validate user form fields.

import Foundation

struct UserValidator {

    static func validateIsNotEmpty(_ field: String, for fieldName: SignInSignUpField) -> String? {
        if let errorMessage = ValidationHelper.isFieldEmpty(field, for: fieldName) {
            return errorMessage
        }
        return nil
    }

    static func validateIsTrue(_ condition: Bool, for fieldName: SignInSignUpField) -> String? {
        if let errorMessage = ValidationHelper.isFieldTrue(condition, for: fieldName) {
            return errorMessage
        }
        return nil
    }

    static func validateEmail(_ email: String) -> String? {
        if let errorMessage = ValidationHelper.isFieldEmpty(email, for: .email) {
            return errorMessage
        }

        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email) ? nil : "Invalid email address"
    }

    // Purpose: Use for Password Validation
    static func validatePassword(_ password: String) -> String? {
        if let errorMessage = ValidationHelper.isFieldEmpty(password, for: .password) {
            return errorMessage
        }

        return password.count >= 8 ? nil : "Password must be at least 8 characters long"
    }

    // Purpose: Use for confirming that password matches confirm password
    static func checkPasswordMatch(_ password: String, confirmPassword: String) -> String? {
        if let errorMessage = ValidationHelper.isFieldEmpty(confirmPassword, for: .confirmPassword) {
            return errorMessage
        }

        return password == confirmPassword ? nil : "Passwords do not match"
    }
}
