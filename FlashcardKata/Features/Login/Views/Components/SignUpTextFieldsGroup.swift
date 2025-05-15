//
//  SignUpTextFieldsGroup.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Group of authentication text fields for the sign up form.

import SwiftUI

/// A view that displays a group of text fields for signing up with email and password,
/// with corresponding error messages for validation.
struct SignUpTextFieldsGroup: View {
    // MARK: - Properties
    /// The credentials for signing up with email and password.
    @Binding var signUpCredentials: EmailPasswordSignUpCredentials
    /// The password confirmation field.
    @Binding var confirmPassword: String
    /// A dictionary of error messages for each field.
    @Binding var errors: [SignInSignUpField: String]
    

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Name field with its associated error message
            nameTextField
            errorMessage(for: .name)

            // Email field with its associated error message
            emailTextField
            errorMessage(for: .email)

            // Password field with its associated error message
            passwordTextField
            errorMessage(for: .password)

            // Confirm password field with its associated error message
            confirmPasswordTextField
            errorMessage(for: .confirmPassword)
        }
    }
    
    // MARK: - Helper Views
    /// Text field for entering the user's name.
    private var nameTextField: some View {
        AuthenticationTextField(
            text: $signUpCredentials.name,
            symbol: SignInSignUpField.name.symbol,
            textFieldLabel: SignInSignUpField.name.description
        )
        .autocapitalization(.words)
    }
    
    /// Text field for entering the user's email address.
    private var emailTextField: some View {
        AuthenticationTextField(
            text: $signUpCredentials.email,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: SignInSignUpField.email.description
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
        .keyboardType(.emailAddress)
    }
    
    /// Text field for entering the user's password.
    private var passwordTextField: some View {
        AuthenticationTextField(
            text: $signUpCredentials.password,
            symbol: SignInSignUpField.password.symbol,
            textFieldLabel: SignInSignUpField.password.description,
            isTextFieldSecure: true
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
    }
    
    /// Text field for confirming the user's password.
    private var confirmPasswordTextField: some View {
        AuthenticationTextField(
            text: $confirmPassword,
            symbol: SignInSignUpField.confirmPassword.symbol,
            textFieldLabel: SignInSignUpField.confirmPassword.description,
            isTextFieldSecure: true
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
    }
    
    // MARK: - Private Methods
    /// Displays error message for authentication text field, if any.
    /// - Parameter fieldName: The field name for which the error message is displayed.
    private func errorMessage(for fieldName: SignInSignUpField) -> some View {
        Group {
            if let error = errors[fieldName] {
                // Display error message if available
                Text(error)
            } else {
                // Display an empty string if no error message is present
                Text("")
            }
        }
        .foregroundStyle(.red)
        .font(.customCaption)
        .padding(.leading, 30)
    }
}

// MARK: - Preview
#Preview {
    SignUpTextFieldsGroup(
        signUpCredentials: .constant(EmailPasswordSignUpCredentials()),
        confirmPassword: .constant(""),
        errors: .constant([:])
    )
}
