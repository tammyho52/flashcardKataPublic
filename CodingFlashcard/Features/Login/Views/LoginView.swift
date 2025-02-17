//
//  LoginView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    // MARK: - State and Dependencies
    @ObservedObject var vm: LandingPageViewModel
    @State private var showLegalAgreementView: Bool = false
    @State private var authenticationProvider: AuthenticationProvider = .guest
    @Binding var viewType: LandingViewType
    
    // MARK: - Constants
    let title = "Login"
    let buttonTitle = "Sign In"
    
    // MARK: - Body
    var body: some View {
        if showLegalAgreementView {
            LegalAgreementView(
                vm: vm,
                showLegalAgreementView: $showLegalAgreementView,
                authenticationProvider: authenticationProvider
            )
        } else {
            VStack(spacing: Padding.mediumVertical) {
                SectionTitle(text: title)
                emailTextField
                passwordTextField
                signInButton
                googleSignInButton
                signInWithAppleButton
                
                VStack {
                    createAccountButton
                    resetPasswordButton
                    enterWithoutSignupButton
                }
                .padding(.top, 10)
            }
            .standardSectionStyle()
            .onAppear {
                vm.setupLoginValidation()
            }
            .addToast(toast: $vm.emailErrorToast)
            .addToast(toast: $vm.authenticationErrorToast)
        }
    }
    
    // MARK: - Text Fields
    var emailTextField: some View {
        AuthenticationTextField(
            text: $vm.emailPasswordLoginCredentials.email,
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
            text: $vm.emailPasswordLoginCredentials.password,
            symbol: SignInSignUpField.password.symbol,
            textFieldLabel: SignInSignUpField.password.description,
            isTextFieldSecure: true
        )
        .textContentType(.none)
        .autocorrectionDisabled(true)
        .autocapitalization(.none)
    }
    
    // MARK: - Primary Action Buttons
    private var signInButton: some View {
        PrimaryButton(
            isDisabled: vm.isLoginButtonDisabled,
            text: buttonTitle,
            action: {
                Task {
                    await vm.emailSignIn()
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
                    await vm.continueWithoutAccount()
                }
            }
        )
    }
}

#if DEBUG
#Preview {
    LoginView(
        vm: LandingPageViewModel(authenticationManager: AuthenticationManager(), webViewService: WebViewService()),
        viewType: .constant(.login)
    )
}
#endif
