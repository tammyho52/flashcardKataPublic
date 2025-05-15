//
//  PasswordResetView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A view that allows users to reset their password by entering their email address.

import SwiftUI

/// A view that enables users to request a password reset email by entering their email address.
struct PasswordResetView: View {
    // MARK: - Properties
    @MainActor @State private var email: String = ""
    @MainActor @State private var toast: Toast?

    let passwordResetAction: (String) async throws -> Void
    let switchToLoginScreen: () -> Void

    // MARK: - Constants
    private let sectionTitle = "Password Reset"
    private let buttonTitle = "Send Email"

    // MARK: - Body
    var body: some View {
        VStack(spacing: Padding.largeVertical) {
            AuthenticationSectionTitle(text: sectionTitle)
            emailField
            sendPasswordResetEmailButton
            switchToAccountLoginButton
        }
        .standardSectionStyle()
        .addToast(toast: $toast)
    }
    
    // MARK: - Helper Views
    private var emailField: some View {
        AuthenticationTextField(
            text: $email,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: SignInSignUpField.email.description
        )
    }

    private var sendPasswordResetEmailButton: some View {
        PrimaryButton(
            isDisabled: email.isEmpty,
            text: buttonTitle
        ) {
            Task {
                defer { email = "" }
                do {
                    try await passwordResetAction(email)
                    toast = Toast(style: .success, message: "Password Reset Email has been sent.")
                } catch {
                    updateErrorToast(error, errorToast: $toast)
                    reportError(error)
                }

            }
        }
    }

    private var switchToAccountLoginButton: some View {
        SecondaryButton(
            text: "Account Login",
            symbol: "person.fill",
            action: switchToLoginScreen
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.customSecondary
            .edgesIgnoringSafeArea(.all)
        PasswordResetView(
            passwordResetAction: { _ in },
            switchToLoginScreen: {}
        )
    }
}

#Preview {
    ZStack {
        Color.customSecondary
            .edgesIgnoringSafeArea(.all)
        PasswordResetView(
            passwordResetAction: { _ in},
            switchToLoginScreen: {}
        )
    }
}
#endif
