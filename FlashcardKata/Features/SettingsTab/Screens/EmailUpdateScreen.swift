//
//  EmailUpdateScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view provides a secure and user-friendly interface for updating the user's email address.

import SwiftUI

/// A view that allows users to update their email address by sending a confirmation email.
struct EmailUpdateScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SettingsViewModel
    @State private var currentPassword: String = ""
    @State private var newEmail: String = ""
    @MainActor @State private var isSending: Bool = false
    @MainActor @State private var toast: Toast?

    let buttonTitle = "Update Email"
    var isDisabled: Bool {
        currentPassword.isEmpty || newEmail.isEmpty
    }

    // MARK: - Body
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
            .navigationBarTitleDisplayMode(.inline)
            .applyOverlayProgressScreen(isViewDisabled: $isSending)
            .toolbar {
                toolbarBackButton { dismiss() }
            }
        }
    }
    
    // MARK: - Private Views
    private var currentPasswordTextField: some View {
        AuthenticationTextField(
            text: $currentPassword,
            symbol: SignInSignUpField.password.symbol,
            textFieldLabel: "Current Password",
            isTextFieldSecure: true
        )
        .autocorrectionDisabled()
        .textContentType(nil)
    }

    private var newEmailTextField: some View {
        AuthenticationTextField(
            text: $newEmail,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: "New Email"
        )
    }

    private var updateEmailButton: some View {
        Button("Update Email") {
            isSending = true
            Task {
                defer { isSending = false }
                do {
                    try await viewModel.updateUserEmail(newEmail: newEmail, password: currentPassword)
                    toast = Toast(style: .success, message: "Update email has been sent.")
                    currentPassword = ""
                    newEmail = ""
                } catch {
                    toast = Toast(style: .error, message: "Update email could not be sent.")
                    reportError(error)
                }
            }
        }
        .buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    EmailUpdateScreen(
        viewModel: SettingsViewModel(
            authenticationManager: FirebaseAuthenticationManager(),
            databaseManager: MockDatabaseManager(),
            webViewService: WebViewService()
        )
    )
}
#endif
