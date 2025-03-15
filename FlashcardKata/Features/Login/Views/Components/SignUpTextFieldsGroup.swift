//
//  SignUpTextFieldsGroup.swift
//  FlashcardKata
//
//  Created by Tammy Ho on 2/25/25.
//
//  Group of authentication text fields for sign up form.

import SwiftUI

struct SignUpTextFieldsGroup: View {
    @Binding var signUpCredentials: EmailPasswordSignUpCredentials
    @Binding var confirmPassword: String
    @Binding var errors: [SignInSignUpField: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            AuthenticationTextField(
                text: $signUpCredentials.name,
                symbol: SignInSignUpField.name.symbol,
                textFieldLabel: SignInSignUpField.name.description
            )
            .autocapitalization(.words)
            errorMessage(for: .name)

            AuthenticationTextField(
                text: $signUpCredentials.email,
                symbol: SignInSignUpField.email.symbol,
                textFieldLabel: SignInSignUpField.email.description
            )
            .textContentType(.none)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            errorMessage(for: .email)

            AuthenticationTextField(
                text: $signUpCredentials.password,
                symbol: SignInSignUpField.password.symbol,
                textFieldLabel: SignInSignUpField.password.description,
                isTextFieldSecure: true
            )
            .textContentType(.none)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            errorMessage(for: .password)

            AuthenticationTextField(
                text: $confirmPassword,
                symbol: SignInSignUpField.confirmPassword.symbol,
                textFieldLabel: SignInSignUpField.confirmPassword.description,
                isTextFieldSecure: true
            )
            .textContentType(.none)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            errorMessage(for: .confirmPassword)
        }
    }

    // Displays error message for authentication text field, if any.
    private func errorMessage(for fieldName: SignInSignUpField) -> some View {
        Group {
            if let error = errors[fieldName] {
                Text(error)
            } else {
                Text("")
            }
        }
        .foregroundStyle(.red)
        .font(.customCaption)
        .padding(.leading, 30)
    }
}

#Preview {
    SignUpTextFieldsGroup(
        signUpCredentials: .constant(EmailPasswordSignUpCredentials()),
        confirmPassword: .constant(""),
        errors: .constant([:])
    )
}
