//
//  EmailUpdateScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for updating user's email by sending an email to the new email.

import SwiftUI

struct EmailUpdateScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    @State private var currentPassword: String = ""
    @State private var newEmail: String = ""
    @State private var isSending: Bool = false
    @State private var toast: Toast?

    let buttonTitle = "Update Email"
    var isDisabled: Bool {
        currentPassword.isEmpty || newEmail.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                currentPasswordTextField
                newEmailTextField
                updateEmailButton
                Spacer()
            }
            .padding([.horizontal, .top])
            .addToast(toast: $toast)
            .navigationTitle("Update Email")
            .applyOverlayProgressScreen(isViewDisabled: $isSending)
            .toolbar {
                toolbarBackButton { dismiss() }
            }
        }
    }

    var currentPasswordTextField: some View {
        AuthenticationTextField(
            text: $currentPassword,
            symbol: SignInSignUpField.password.symbol,
            textFieldLabel: "Current Password",
            isTextFieldSecure: true
        )
        .autocorrectionDisabled()
        .textContentType(nil)
    }

    var newEmailTextField: some View {
        AuthenticationTextField(
            text: $newEmail,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: "New Email"
        )
    }

    var updateEmailButton: some View {
        Button("Update Email") {
            Task {
                do {
                    isSending = true
                    defer { isSending = false }
                    try await viewModel.updateUserEmail(newEmail: newEmail, password: currentPassword)
                    toast = Toast(style: .success, message: "Update email has been sent.")
                    currentPassword = ""
                    newEmail = ""
                } catch {
                    toast = Toast(style: .error, message: "Update email could not be sent.")
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
    }
}

#if DEBUG
#Preview {
    EmailUpdateScreen(
        viewModel: SettingsViewModel(
            authenticationManager: AuthenticationManager(),
            databaseManager: MockDatabaseManager(),
            webViewService: WebViewService()
        )
    )
}
#endif
