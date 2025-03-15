//
//  LandingPageViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View Model for user authentication views.

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import Combine
import SwiftUI
import AuthenticationServices
import CryptoKit

final class LandingPageViewModel: ObservableObject {

    // MARK: - Dependencies
    @AppStorage(UserDefaultsKeys.authenticationProvider) var authenticationProvider: AuthenticationProvider?
    @ObservedObject var webViewService: WebViewService

    // MARK: - Authentication State
    @Published var emailPasswordLoginCredentials: EmailPasswordLoginCredentials = EmailPasswordLoginCredentials()
    @Published var signUpCredentials: EmailPasswordSignUpCredentials = EmailPasswordSignUpCredentials()
    @Published var confirmPassword: String = ""

    // MARK: - UI State Management
    @Published var webViewType: WebViewType?
    @Published var showWebView: Bool
    @Published var showWebViewAlert: Bool
    @Published var alertTitle: String
    @Published var alertMessage: String
    @Published var webViewURL: URL?
    @Published var isLoginButtonDisabled: Bool = true
    @Published var isSignUpButtonDisabled: Bool = true
    @Published var emailErrorToast: Toast?
    @Published var authenticationErrorToast: Toast?

    // MARK: - Error Handling
    @Published var errors: [SignInSignUpField: String] = [:]

    // MARK: - Managers / Services
    let authenticationManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()

    var currentNonce: String?
    var userID: String {
        authenticationManager.userID
    }

    // MARK: - Constants
    let privatePolicyURLString: String = ContentConstants.ContentStrings.privatePolicyURL
    let termsAndConditionsURLString: String = ContentConstants.ContentStrings.termsAndConditionsURL
    let debounceMilliseconds: Int = 750

    // MARK: - Initialization
    init(authenticationManager: AuthenticationManager, webViewService: WebViewService) {
        self.authenticationManager = authenticationManager
        self.webViewService = webViewService
        self.showWebView = webViewService.showWebView
        self.showWebViewAlert = webViewService.showAlert
        self.alertTitle = webViewService.alertTitle
        self.alertMessage = webViewService.alertMessage
        self.webViewURL = webViewService.webViewURL

        // Binds web view service properties to view model properties.
        webViewService.$showWebView
            .assign(to: &$showWebView)
        webViewService.$showAlert
            .assign(to: &$showWebViewAlert)
        webViewService.$alertTitle
            .assign(to: &$alertTitle)
        webViewService.$alertMessage
            .assign(to: &$alertMessage)
        webViewService.$webViewURL
            .assign(to: &$webViewURL)

        // Binds authentication manager error toast to view model property.
        authenticationManager.$authenticationToast
            .assign(to: &$authenticationErrorToast)
    }

    // Clear all credentials and reset state.
    func clearCredentials() {
        emailPasswordLoginCredentials = EmailPasswordLoginCredentials()
        signUpCredentials = EmailPasswordSignUpCredentials()
        confirmPassword = ""
    }

    // MARK: - Guest Methods
    @MainActor
    func continueWithoutAccount() async {
        await authenticationManager.continueWithoutAccount()
    }

    // MARK: - Email/Password Authentication Methods
    private func emailSignIn(email: String, password: String) async throws {
        try await authenticationManager.emailSignIn(email: email, password: password)
    }

    @MainActor
    func emailSignIn() async {
        do {
            try await emailSignIn(
                email: emailPasswordLoginCredentials.email,
                password: emailPasswordLoginCredentials.password
            )
            try await authenticationManager.syncUserEmailWithUserProfile()
            clearCredentials()
        } catch {
            emailErrorToast = Toast(style: .error, message: "Email Sign in failed. Please check your credentials.")
        }
    }

    @MainActor
    func emailSignUpAndSignIn() async {
        if validateEmailSignUpCredentials() {
            do {
                try await authenticationManager.emailSignUp(
                    name: signUpCredentials.name,
                    email: signUpCredentials.email,
                    password: signUpCredentials.password
                )
                clearCredentials()
            } catch let signUpError as NSError {
                if signUpError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    do {
                        try await emailSignIn(email: signUpCredentials.email, password: signUpCredentials.password)
                    } catch {
                        setEmailErrorToast()
                    }
                } else {
                    setEmailErrorToast()
                }
            }
        } else {
            setEmailErrorToast()
        }
    }

    private func setEmailErrorToast() {
        emailErrorToast = Toast(
            style: .warning,
            message: "Email sign up failed. Please try again."
        )
    }

    // MARK: - Google Authentication Methods
    @MainActor
    func handleGoogleSignInAndSignUp() async throws {
        await authenticationManager.signInWithGoogle()
    }

    // MARK: - Apple Authentication Methods
    @MainActor
    func handleAppleSignInAndSignUp() async throws {
        await authenticationManager.signInWithApple()
    }

    // MARK: - Password Management
    @MainActor
    func sendPasswordResetEmail(email: String) async {
        try? await authenticationManager.sendPasswordResetEmail(email: email)
    }

    // MARK: - Validation Methods
    @MainActor
    func setupLoginValidation() {
        Publishers.CombineLatest(
            $emailPasswordLoginCredentials.map(\.email),
            $emailPasswordLoginCredentials.map(\.password)
        )
        .debounce(for: .milliseconds(debounceMilliseconds), scheduler: RunLoop.main)
        .map { email, password in
            let isEmailInvalid = email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let isPasswordInvalid = password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return isEmailInvalid || isPasswordInvalid
        }
        .assign(to: &$isLoginButtonDisabled)
    }

    @MainActor
    func setupSignUpValidation() {
        Publishers.CombineLatest4(
            $signUpCredentials.map(\.email),
            $signUpCredentials.map(\.password),
            $signUpCredentials.map(\.name),
            $signUpCredentials.map(\.agreedToLegal)
        )
        .debounce(for: .milliseconds(debounceMilliseconds), scheduler: RunLoop.main)
        .map { email, password, name, agreedToLegal in
            let isEmailInvalid = email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let isPasswordInvalid = password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let isNameInvalid = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasNotAgreedToLegal = !agreedToLegal
            return isEmailInvalid || isPasswordInvalid || isNameInvalid || hasNotAgreedToLegal
        }
        .assign(to: &$isSignUpButtonDisabled)
    }

    func validateEmailSignUpCredentials() -> Bool {
        errors.removeAll()
        if let error = UserValidator.validateIsNotEmpty(signUpCredentials.name, for: .name) {
            errors[.name] = error
        }
        if let error = UserValidator.validateEmail(signUpCredentials.email) {
            errors[.email] = error
        }
        if let error = UserValidator.validatePassword(signUpCredentials.password) {
            errors[.password] = error
        }
        if let error = UserValidator.checkPasswordMatch(signUpCredentials.password, confirmPassword: confirmPassword) {
            errors[.confirmPassword] = error
        }
        if let error = UserValidator.validateIsTrue(signUpCredentials.agreedToLegal, for: .agreedToLegal) {
            errors[.agreedToLegal] = error
        }
        return errors.isEmpty
    }

    // MARK: - Web View Management
    private func loadWebView(urlString: String, type: WebViewType) {
        webViewService.loadWebView(urlString: urlString, type: type)
    }

    @MainActor
    func loadPrivacyPolicyWebView() {
        loadWebView(urlString: privatePolicyURLString, type: .privatePolicy)
        webViewType = .privatePolicy
    }

    @MainActor
    func loadTermsAndConditionsWebView() {
        loadWebView(urlString: termsAndConditionsURLString, type: .termsAndConditons)
        webViewType = .termsAndConditons
    }

    @MainActor
    func handleWebViewError() {
        if let webViewType {
            webViewService.handleWebViewError(type: webViewType)
        }
    }

    @MainActor
    func dismissWebView() {
        webViewService.dismissWebView()
    }
}
