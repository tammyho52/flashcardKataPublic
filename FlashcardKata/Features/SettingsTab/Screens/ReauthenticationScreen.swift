//
//  ReauthenticationScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view provides a secure interface for email/password reauthentication
//  required prior to sensitive actions like account deletion.

import SwiftUI

/// A view for email/password reauthentication before sensitive actions like account deletion.
struct ReauthenticationScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""

    let buttonAction: (_ email: String, _ password: String) async -> Void
    let buttonTitle = "Delete Account"
    var isDisabled: Bool {
        email.isEmpty || password.isEmpty
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    emailTextField
                    passwordTextField
                    accountDeletionWarningText

                    PrimaryButton(
                        isDisabled: isDisabled,
                        text: buttonTitle,
                        action: { await buttonAction(email, password) }
                    )
                    .padding(.top)
                }
            }
            .padding([.horizontal, .top])
            .navigationTitle("Reauthentication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarBackButton { dismiss() }
            }
        }
    }

    // MARK: - Private Views
    private var emailTextField: some View {
        AuthenticationTextField(
            text: $email,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: SignInSignUpField.email.description
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
        .keyboardType(.emailAddress)
    }

    private var passwordTextField: some View {
        AuthenticationTextField(
            text: $password,
            symbol: SignInSignUpField.password.symbol,
            textFieldLabel: SignInSignUpField.password.description,
            isTextFieldSecure: true
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
    }

    private var accountDeletionWarningText: some View {
        Text("Deleted account information cannot be recovered.")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.red)
            .padding(.horizontal)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ReauthenticationScreen(buttonAction: { _, _ in })
}
#endif
