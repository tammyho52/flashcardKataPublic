//
//  SignUpView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Sign up view with different options (Email/password, Google, Apple) and navigation back to Account Login.

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignUpView: View {
    @ObservedObject var viewModel: LandingPageViewModel
    @State private var webViewType: WebViewType = .termsAndConditons
    @State private var showLegalAgreementView: Bool = false
    @State private var authenticationProvider: AuthenticationProvider = .emailPassword
    @Binding var viewType: LandingViewType

    let switchToLoginScreen: () -> Void
    let title = "Sign Up"
    let buttonTitle = "Create Account"

    var body: some View {
        if showLegalAgreementView {
            LegalAgreementView(
                viewModel: viewModel,
                showLegalAgreementView: $showLegalAgreementView,
                authenticationProvider: authenticationProvider
            )
        } else {
            VStack(spacing: Padding.mediumVertical) {
                AuthenticationSectionTitle(text: title)
                SignUpTextFieldsGroup(
                    signUpCredentials: $viewModel.signUpCredentials,
                    confirmPassword: $viewModel.confirmPassword,
                    errors: $viewModel.errors
                )
                legalAgreementButton
                createAccountButton
                HStack(spacing: 50) {
                    googleSignUpButton()
                    appleSignUpButton()
                }
                .padding(.vertical, 10)
                accountLoginButton
            }
            .standardSectionStyle()
            .onAppear {
                viewModel.setupSignUpValidation()
            }
            .sheet(isPresented: $viewModel.showWebView) {
                if let url = viewModel.webViewURL {
                    WebView(
                        url: url,
                        onFinishedLoading: nil,
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

    // MARK: - Buttons
    var createAccountButton: some View {
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

    var accountLoginButton: some View {
        SecondaryButton(
            text: "Account Login",
            symbol: "person.fill",
            action: switchToLoginScreen
        )
    }

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

    // Legal Agreement checkbox with tappable links to legal agreements.
    var legalAgreementButton: some View {
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
                        text: "Private Policy",
                        action: viewModel.loadPrivacyPolicyWebView
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ZStack {
            Color.customAccent
            SignUpView(
                viewModel: LandingPageViewModel(
                    authenticationManager: AuthenticationManager(),
                    webViewService: WebViewService()
                ),
                viewType: .constant(.signUp),
                switchToLoginScreen: {}
            )
        }
    }
}
#endif
