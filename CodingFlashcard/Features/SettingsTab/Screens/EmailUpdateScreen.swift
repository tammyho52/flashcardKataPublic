//
//  EmailUpdateScreen.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct EmailUpdateScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: SettingsViewModel
    @State var currentPassword: String = ""
    @State var newEmail: String = ""
    @State private var isSending: Bool = false
    @State private var toast: Toast?
    
    let buttonTitle = "Update Email"
    var isDisabled: Bool {
        currentPassword.isEmpty || newEmail.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AuthenticationTextField(
                    text: $currentPassword,
                    symbol: SignInSignUpField.password.symbol,
                    textFieldLabel: "Current Password",
                    isTextFieldSecure: true
                )
                .autocorrectionDisabled()
                .textContentType(nil)

                AuthenticationTextField(
                    text: $newEmail,
                    symbol: SignInSignUpField.email.symbol,
                    textFieldLabel: "New Email"
                )
                Button("Update Email") {
                    Task {
                        do {
                            isSending = true
                            defer { isSending = false }
                            try await vm.updateUserEmail(newEmail: newEmail, password: currentPassword)
                            toast = Toast(style: .success, message: "Update email has been sent.")
                            currentPassword = ""
                            newEmail = ""
                        } catch {
                            toast = Toast(style: .error, message: "Update email could not be sent.")
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
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
}

#if DEBUG
#Preview {
    EmailUpdateScreen(vm: SettingsViewModel(authenticationManager: AuthenticationManager(), databaseManager: MockDatabaseManager(), webViewService: WebViewService()))
}
#endif
