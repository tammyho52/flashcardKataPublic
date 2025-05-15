//
//  UserValidator.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure containing utility methods to validate user form fields.

import Foundation

/// Enum representing the different validation methods in the sign-in/sign-up process with error strings if validation fails.
struct UserValidator {
    /// Validates if a field is not empty.
    static func validateIsNotEmpty(_ field: String, for fieldName: SignInSignUpField) -> String? {
        if let errorMessage = isFieldEmpty(field, for: fieldName) {
            return errorMessage
        }
        return nil
    }

    /// Validates if a field is true.
    static func validateIsTrue(_ condition: Bool, for fieldName: SignInSignUpField) -> String? {
        if let errorMessage = isFieldTrue(condition, for: fieldName) {
            return errorMessage
        }
        return nil
    }

    /// Validates if the email format is correct.
    static func validateEmail(_ email: String) -> String? {
        if let errorMessage = isFieldEmpty(email, for: .email) {
            return errorMessage
        }

        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email) ? nil : "Invalid email address"
    }

    /// Validates if the password meets the minimum length requirement.
    static func validatePassword(_ password: String) -> String? {
        if let errorMessage = isFieldEmpty(password, for: .password) {
            return errorMessage
        }

        return password.count >= 8 ? nil : "Password must be at least 8 characters long"
    }

    /// Validates if the password and confirm password fields match.
    static func checkPasswordMatch(_ password: String, confirmPassword: String) -> String? {
        if let errorMessage = isFieldEmpty(confirmPassword, for: .confirmPassword) {
            return errorMessage
        }

        return password == confirmPassword ? nil : "Passwords do not match"
    }
    
    // MARK: - Helper Methods
    /// Helper methods to check if a field is empty.
    static private func isFieldEmpty(_ value: String, for fieldName: SignInSignUpField) -> String? {
        return value.isEmpty ? "\(fieldName.description) is required" : nil
    }
    
    /// Helper method to check if a field has been agreed to.
    static private func isFieldTrue(_ condition: Bool, for fieldName: SignInSignUpField) -> String? {
        return condition == false ? "Please agree to the \(fieldName.description) to proceed." : nil
    }
}
