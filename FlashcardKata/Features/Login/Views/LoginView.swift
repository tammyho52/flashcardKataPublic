//
//  LoginView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays login screen with options for signing in via email/password, Apple, or Google, with
//  navigation to account creation, password reset, or guest access.

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

/// A view that presents the main login interface, allowing users to:
/// - Sign in via email/password
/// - Authenticate with Apple or Google
/// - Navigate to account creation or password reset
/// - Continue without an account as guest user
struct LoginView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: LandingPageViewModel
    
    /// Controls display of legal agreement view required for third-party authentication.
    @State private var showLegalAgreementView: Bool = false
    
    /// Tracks the selected authentication provider.
    @State private var authenticationProvider: AuthenticationProvider = .guest
    
    /// Binding to manage the view type for navigation.
    @Binding var viewType: LandingViewType

    // MARK: - Constants
    private let title = "Login"
    private let buttonTitle = "Sign In"

    // MARK: - Body
    var body: some View {
        if showLegalAgreementView {
            // Display legal agreement view if user selects third-party authentication
            LegalAgreementView(
                viewModel: viewModel,
                showLegalAgreementView: $showLegalAgreementView,
                authenticationProvider: authenticationProvider
            )
        } else {
            // Main login view
            VStack(spacing: Padding.mediumVertical) {
                // Email/Password Sign In
                emailPasswordSignInSection

                // Third-party authentication methods
                googleSignInButton
                signInWithAppleButton

                // Navigation options to alternate actions
                VStack {
                    createAccountButton
                    resetPasswordButton
                    enterWithoutSignupButton
                }
                .padding(.top, 10)
            }
            .standardSectionStyle()
            .onAppear {
                viewModel.setupLoginValidation()
            }
            .addToast(toast: $viewModel.emailErrorToast)
            .addToast(toast: $viewModel.authenticationErrorToast)
        }
    }

    // MARK: - Login Text Fields
    /// A section containing the email and password text fields for login.
    private var emailPasswordSignInSection: some View {
        Group {
            AuthenticationSectionTitle(text: title)
            emailTextField
                .accessibilityIdentifier("emailTextField")
            passwordTextField
                .accessibilityIdentifier("passwordTextField")
            signInButton
                .accessibilityIdentifier("signInButton")
        }
    }
    
    /// A text field for entering the user's email address.
    private var emailTextField: some View {
        AuthenticationTextField(
            text: $viewModel.emailPasswordLoginCredentials.email,
            symbol: SignInSignUpField.email.symbol,
            textFieldLabel: SignInSignUpField.email.description
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
        .keyboardType(.emailAddress)
    }
    
    /// A text field for entering the user's password.
    private var passwordTextField: some View {
        AuthenticationTextField(
            text: $viewModel.emailPasswordLoginCredentials.password,
            symbol: SignInSignUpField.password.symbol,
            textFieldLabel: SignInSignUpField.password.description,
            isTextFieldSecure: true
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
    }

    // MARK: - Action Buttons
    /// A button that triggers the email/password sign-in process.
    private var signInButton: some View {
        PrimaryButton(
            isDisabled: viewModel.isLoginButtonDisabled,
            text: buttonTitle,
            action: {
                Task {
                    await viewModel.emailSignIn()
                }
            }
        )
    }

    /// A button that allows the user to sign in using Google.
    private var googleSignInButton: some View {
        GoogleSignInButton(
            viewModel: GoogleSignInButtonViewModel(
                scheme: .light,
                style: .wide,
                state: .normal)
        ) {
            authenticationProvider = .google
            showLegalAgreementView = true
        }
    }

    /// A button that allows the user to sign in using Apple.
    private var signInWithAppleButton: some View {
        Button {
            authenticationProvider = .apple
            showLegalAgreementView = true
        } label: {
            SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                .allowsHitTesting(false)
        }
        .frame(height: 50)
    }
    
    /// A button that allows the user to navigate to create a new account screen.
    private var createAccountButton: some View {
        SecondaryButton(
            text: "Create Account",
            symbol: "person.fill",
            action: { viewType = .signUp }
        )
    }
    
    /// A button that allows the user to navigate to reset password screen.
    private var resetPasswordButton: some View {
        SecondaryButton(
            text: "Reset Password",
            symbol: "lock.fill",
            action: { viewType = .passwordReset }
        )
    }

    /// A button that allows the user to continue without creating an account.
    private var enterWithoutSignupButton: some View {
        SecondaryButton(
            text: "Continue Without Account",
            symbol: ContentConstants.Symbols.signUpAndLogin,
            action: {
                Task {
                    await viewModel.continueWithoutAccount()
                }
            }
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    LoginView(
        viewModel: LandingPageViewModel(
            authenticationManager: AnyAuthenticationManager.sample,
            webViewService: WebViewService()
        ),
        viewType: .constant(.login)
    )
}
#endif
