//
//  SignUpView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A view for account sign up supporting email/password,
//  Google, and Apple authentication with user consent to legal agreements.

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

/// A view that handles the sign-up process for a user with multiple authentication options, and navigation to legal agreements and the login screen.
struct SignUpView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: LandingPageViewModel
    @State private var webViewType: WebViewType = .termsAndConditions
    @State private var showLegalAgreementView: Bool = false
    @State private var authenticationProvider: AuthenticationProvider = .emailPassword
    @Binding var viewType: LandingViewType

    let switchToLoginScreen: () -> Void
    
    // MARK: - Constants
    private let title = "Sign Up"
    private let buttonTitle = "Create Account"

    // MARK: - Body
    var body: some View {
        if showLegalAgreementView {
            // Displays web view legal agreements in-app
            LegalAgreementView(
                viewModel: viewModel,
                showLegalAgreementView: $showLegalAgreementView,
                authenticationProvider: authenticationProvider
            )
        } else {
            // Displays sign-up screen with email/password fields and third-party authentication buttons.
            VStack(spacing: Padding.mediumVertical) {
                AuthenticationSectionTitle(text: title)
                
                // Displays email/password sign-up fields with legal agreement consent.
                emailSignUpSection
                
                // Displays third-party authentication buttons.
                HStack(spacing: 50) {
                    googleSignUpButton()
                    appleSignUpButton()
                }
                .padding(.vertical, 10)
                
                // Navigates back to the login screen.
                accountLoginButton
            }
            .standardSectionStyle()
            .onAppear {                viewModel.setupSignUpValidation()
            }
            .sheet(isPresented: $viewModel.showWebView) {
                // Displays web view for legal agreements.
                if let url = viewModel.webViewURL {
                    WebView(
                        url: url,
                        onError: viewModel.handleWebViewError
                    )
                }
            }
            .addToast(toast: $viewModel.emailErrorToast)
            .addToast(toast: $viewModel.authenticationErrorToast)
            .webViewAlert(
                isPresented: $viewModel.showWebViewAlert,
                title: viewModel.alertTitle,
                message: viewModel.alertMessage,
                dismissAction: viewModel.dismissWebView
            )
        }
    }
    
    // MARK: - Helper Views
    /// Combines email/password sign up fields with legal agreement consent and the create account button.
    @ViewBuilder
    private var emailSignUpSection: some View {
        SignUpTextFieldsGroup(
            signUpCredentials: $viewModel.signUpCredentials,
            confirmPassword: $viewModel.confirmPassword,
            errors: $viewModel.signUpFieldErrors
        )
        legalAgreementButton
        createAccountButton
    }

    // MARK: - Sign Up Buttons
    /// A button that initiates sign up with email/password.
    private var createAccountButton: some View {
        PrimaryButton(
            isDisabled: viewModel.isSignUpButtonDisabled,
            text: buttonTitle,
            action: {
                Task {
                    await viewModel.emailSignUpAndSignIn()
                }
            }
        )
    }
    
    /// A button that allows the user to navigate back to the login screen.
    private var accountLoginButton: some View {
        SecondaryButton(
            text: "Account Login",
            symbol: "person.fill",
            action: switchToLoginScreen
        )
    }
    
    /// Legal Agreement section with a checkbox to agree to legal terms and tappable links to legal agreements.
    private var legalAgreementButton: some View {
        HStack(spacing: 15) {
            CheckboxButton(
                isChecked: $viewModel.signUpCredentials.agreedToLegal
            )
            .padding(.trailing, 10)

            VStack(alignment: .leading) {
                Text("I agree to the ")
                TappableLink(
                    text: "Terms and Conditions",
                    action: viewModel.loadTermsAndConditionsWebView
                )
                HStack(spacing: 0) {
                    Text("and ")
                    TappableLink(
                        text: "Privacy Policy",
                        action: viewModel.loadPrivacyPolicyWebView
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Third-Party Authentication Buttons
    /// A button that allows the user to sign up with Google and present legal agreement view.
    private func googleSignUpButton() -> some View {
        GoogleSignInButton(
            viewModel: GoogleSignInButtonViewModel(
                scheme: .light,
                style: .icon,
                state: .normal)
        ) {
            authenticationProvider = .google
            showLegalAgreementView = true
        }
        .scaleEffect(1.5)
    }

    /// A button that allows the user to sign up with Apple and present legal agreement view.
    private func appleSignUpButton() -> some View {
        Button {
            authenticationProvider = .apple
            showLegalAgreementView = true
        } label: {
            Image("AppleIcon")
                .cornerRadius(12)
                .applyCoverShadow()
                .scaleEffect(1.5)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        ZStack {
            Color.customAccent
            SignUpView(
                viewModel: LandingPageViewModel(
                    authenticationManager: AnyAuthenticationManager.sample,
                    webViewService: WebViewService()
                ),
                viewType: .constant(.signUp),
                switchToLoginScreen: {}
            )
        }
    }
}
#endif
