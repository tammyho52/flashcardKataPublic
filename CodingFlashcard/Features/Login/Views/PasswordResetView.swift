//
//  PasswordResetView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct PasswordResetView: View {
    // MARK: - State Management
    @State var email: String = ""
    @State var toast: Toast?
    
    // MARK: - Constants
    let sectionTitle = "Password Reset"
    let buttonTitle = "Send Email"
    
    // MARK: - Configuration
    let passwordResetAction: (String) async -> Void
    let switchToLoginScreen: () -> Void
    
    // MARK: - Computed Properties
    var isSaveButtonDisabled: Bool {
        email.isEmpty
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: Padding.largeVertical) {
            SectionTitle(text: sectionTitle)
            emailField
            sendPasswordResetEmailButton
            switchToAccountLoginButton
        }
        .standardSectionStyle()
        .addToast(toast: $toast)
    }
    
    // MARK: - Email Field
    @ViewBuilder
    private var emailField: some View {
        AuthenticationTextField(
            text: $email,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: SignInSignUpField.email.description
        )
    }
    
    // MARK: - Action Buttons
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
