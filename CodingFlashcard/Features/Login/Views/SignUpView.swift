//
//  SignUpView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignUpView: View {
    // MARK: - State and Dependencies
    @ObservedObject var vm: LandingPageViewModel
    @State private var webViewType: WebViewType = .termsAndConditons
    @State private var showLegalAgreementView: Bool = false
    @State private var authenticationProvider: AuthenticationProvider = .emailPassword
    @Binding var viewType: LandingViewType
    
    let switchToLoginScreen: () -> Void
    
    // MARK: - Constants
    let title = "Sign Up"
    let buttonTitle = "Create Account"
    
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
                SignUpTextFieldsGroup(
                    signUpCredentials: $vm.signUpCredentials,
                    confirmPassword: $vm.confirmPassword,
                    errors: $vm.errors
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
                vm.setupSignUpValidation()
            }
            .sheet(isPresented: $vm.showWebView) {
                if let url = vm.webViewURL {
                    WebView(
                        url: url,
                        onFinishedLoading: nil,
                        onError: vm.handleWebViewError
                    )
                }
            }
            .addToast(toast: $vm.emailErrorToast)
            .addToast(toast: $vm.authenticationErrorToast)
            .webViewAlert(
                isPresented: $vm.showWebViewAlert,
                title: vm.alertTitle,
                message: vm.alertMessage,
                dismissAction: vm.dismissWebView
            )
        }
    }
    
    // MARK: - Buttons
    var createAccountButton: some View {
        PrimaryButton(
            isDisabled: vm.isSignUpButtonDisabled,
            text: buttonTitle,
            action: {
                Task {
                    await vm.emailSignUpAndSignIn()
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
    
    var legalAgreementButton: some View {
        HStack(spacing: 15) {
            CheckboxButton(
                isChecked: $vm.signUpCredentials.agreedToLegal
            )
            .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text("I agree to the ")
                TappableLink(
                    text: "Terms and Conditions",
                    action: vm.loadTermsAndConditionsWebView
                )
                HStack(spacing: 0) {
                    Text("and ")
                    TappableLink(
                        text: "Private Policy",
                        action: vm.loadPrivacyPolicyWebView
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
}

// MARK: - Sign Up Text Fields
private struct SignUpTextFieldsGroup: View {
    @Binding var signUpCredentials: SignUpCredentials
    @Binding var confirmPassword: String
    @Binding var errors: [SignInSignUpField: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            AuthenticationTextField(
                text: $signUpCredentials.name,
                symbol: SignInSignUpField.name.symbol,
                textFieldLabel: SignInSignUpField.name.description
            )
            .autocapitalization(.words)
            errorMessage(for: .name)

            AuthenticationTextField(
                text: $signUpCredentials.email,
                symbol: SignInSignUpField.email.symbol,
                textFieldLabel: SignInSignUpField.email.description
            )
            .textContentType(.none)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            errorMessage(for: .email)
            
            AuthenticationTextField(
                text: $signUpCredentials.password,
                symbol: SignInSignUpField.password.symbol,
                textFieldLabel: SignInSignUpField.password.description,
                isTextFieldSecure: true
            )
            .textContentType(.none)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            errorMessage(for: .password)
            
            AuthenticationTextField(
                text: $confirmPassword,
                symbol: SignInSignUpField.confirmPassword.symbol,
                textFieldLabel: SignInSignUpField.confirmPassword.description,
                isTextFieldSecure: true
            )
            .textContentType(.none)
            .autocorrectionDisabled(true)
            .autocapitalization(.none)
            errorMessage(for: .confirmPassword)
        }
    }
    
    private func errorMessage(for fieldName: SignInSignUpField) -> some View {
        Group {
            if let error = errors[fieldName] {
                Text(error)
            } else {
                Text("")
            }
        }
        .foregroundStyle(.red)
        .font(.customCaption)
        .padding(.leading, 30)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ZStack {
            Color.customAccent
            SignUpView(
                vm: LandingPageViewModel(authenticationManager: AuthenticationManager(), webViewService: WebViewService()), viewType: .constant(.signUp),
                switchToLoginScreen: {}
            )
        }
    }
}
#endif
