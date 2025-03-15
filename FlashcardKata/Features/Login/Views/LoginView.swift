//
//  LoginView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays login screen with options for login(email/password, Apple, Google) and
//  navigation buttons to create account, reset password, or enter app as Guest.

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var viewModel: LandingPageViewModel
    @State private var showLegalAgreementView: Bool = false
    @State private var authenticationProvider: AuthenticationProvider = .guest
    @Binding var viewType: LandingViewType

    let title = "Login"
    let buttonTitle = "Sign In"

    var body: some View {
        if showLegalAgreementView {
            LegalAgreementView(
                viewModel: viewModel,
                showLegalAgreementView: $showLegalAgreementView,
                authenticationProvider: authenticationProvider
            )
        } else {
            VStack(spacing: Padding.mediumVertical) {
                // Email/Password Sign In
                Group {
                    AuthenticationSectionTitle(text: title)
                    emailTextField
                    passwordTextField
                    signInButton
                }

                // Third-party authentication methods
                Group {
                    googleSignInButton
                    signInWithAppleButton
                }

                // Navigate to alternative authentication options
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
    var emailTextField: some View {
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

    var passwordTextField: some View {
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

    private var createAccountButton: some View {
        SecondaryButton(
            text: "Create Account",
            symbol: "person.fill",
            action: { viewType = .signUp }
        )
    }

    private var resetPasswordButton: some View {
        SecondaryButton(
            text: "Reset Password",
            symbol: "lock.fill",
            action: { viewType = .passwordReset }
        )
    }

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

#if DEBUG
#Preview {
    LoginView(
        viewModel: LandingPageViewModel(
            authenticationManager: AuthenticationManager(),
            webViewService: WebViewService()
        ),
        viewType: .constant(.login)
    )
}
#endif
