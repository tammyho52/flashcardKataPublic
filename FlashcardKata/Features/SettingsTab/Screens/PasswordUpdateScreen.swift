//
//  PasswordUpdateScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view provides an interface for sending a password reset email.

import SwiftUI

/// A view that allows users to update their password by sending a password reset email.
struct PasswordUpdateScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @MainActor @State private var isSending: Bool = false
    @State private var email: String = ""
    @MainActor @State private var toast: Toast?

    let sendPasswordEmail: (String) async throws -> Void
    let buttonTitle = "Update Password"
    var isDisabled: Bool {
        email.isEmpty
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AuthenticationTextField(
                    text: $email,
                    symbol: SignInSignUpField.email.symbol,
                    textFieldLabel: SignInSignUpField.email.description
                )

                Button("Send Email") {
                    isSending = true
                    Task {
                        defer {
                            isSending = false
                            email = ""
                        }
                        await sendEmail()
                        
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
                .padding(.top)

                Spacer()
            }
            .padding([.horizontal, .top])
            .navigationTitle("Update Password")
            .navigationBarTitleDisplayMode(.inline)
            .addToast(toast: $toast, onDismiss: {
                dismiss()
            })
            .applyOverlayProgressScreen(isViewDisabled: $isSending)
            .toolbar {
                toolbarBackButton { dismiss() }
            }
        }
    }
    
    // MARK: - Private Methods
    /// Sends the password reset email to the specified email address.
    private func sendEmail() async {
        do {
            try await sendPasswordEmail(email)
            toast = Toast(style: .success, message: "Password Reset Email has been sent.")
        } catch {
            updateErrorToast(error, errorToast: $toast)
            reportError(error)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    @Previewable @State var showSheet: Bool = true
    NavigationStack {
        // Empty View
    }
    .sheet(isPresented: $showSheet) {
        PasswordUpdateScreen(sendPasswordEmail: { _ in })
    }
}
#endif
