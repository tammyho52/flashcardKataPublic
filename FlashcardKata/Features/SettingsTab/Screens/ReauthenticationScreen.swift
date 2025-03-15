//
//  ReauthenticationScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for email/password reauthentication prior to account deletion.

import SwiftUI

struct ReauthenticationScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""

    let buttonAction: (_ email: String, _ password: String) async -> Void
    let buttonTitle = "Delete Account"
    var isDisabled: Bool {
        email.isEmpty || password.isEmpty
    }

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
            .toolbar {
                toolbarBackButton { dismiss() }
            }
        }
    }

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

#if DEBUG
#Preview {
    ReauthenticationScreen(buttonAction: { _, _ in })
}
#endif
