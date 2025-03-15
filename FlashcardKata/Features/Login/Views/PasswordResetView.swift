//
//  PasswordResetView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Password reset view with email input.

import SwiftUI

struct PasswordResetView: View {
    @State private var email: String = ""
    @State private var toast: Toast?

    let sectionTitle = "Password Reset"
    let buttonTitle = "Send Email"

    let passwordResetAction: (String) async -> Void
    let switchToLoginScreen: () -> Void

    var isSaveButtonDisabled: Bool {
        email.isEmpty
    }

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

    @ViewBuilder
    private var emailField: some View {
        AuthenticationTextField(
            text: $email,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: SignInSignUpField.email.description
        )
    }

    private var sendPasswordResetEmailButton: some View {
        PrimaryButton(
            isDisabled: isSaveButtonDisabled,
            text: buttonTitle
        ) {
            Task {
                await passwordResetAction(email)
                toast = Toast(style: .success, message: "Password Reset Email has been sent.")
                email = ""

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
