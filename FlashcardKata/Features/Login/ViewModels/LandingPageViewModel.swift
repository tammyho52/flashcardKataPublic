//
//  LandingPageViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View model responsible for managing the landing page and authentication process.

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import Combine
import SwiftUI
import AuthenticationServices
import CryptoKit

/// A view model that handles the logic for the landing page, including authentication, form validation, and web view management to display legal agreements.
@MainActor
final class LandingPageViewModel: ObservableObject {
    // MARK: - Dependencies
    @AppStorage(UserDefaultsKeys.authenticationProvider) var authenticationProvider: AuthenticationProvider?
    @ObservedObject var webViewService: WebViewService
    
    // MARK: - Authentication Credentials
    @Published var emailPasswordLoginCredentials: EmailPasswordLoginCredentials = EmailPasswordLoginCredentials()
    @Published var signUpCredentials: EmailPasswordSignUpCredentials = EmailPasswordSignUpCredentials()
    @Published var confirmPassword: String = ""

    // MARK: - Web View State
    @Published var webViewType: WebViewType?
    @Published var showWebView: Bool
    @Published var showWebViewAlert: Bool
    @Published var alertTitle: String
    @Published var alertMessage: String
    @Published var webViewURL: URL?
    
    // MARK: - Button States
    @Published var isLoginButtonDisabled: Bool = true
    @Published var isSignUpButtonDisabled: Bool = true
    
    // MARK: - Toasts
    @Published var emailErrorToast: Toast?
    @Published var authenticationErrorToast: Toast?

    // MARK: - Error Handling
    @Published var signUpFieldErrors: [SignInSignUpField: String] = [:]

    // MARK: - Managers / Services
    let authenticationManager: AnyAuthenticationManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - User Data
    var currentNonce: String?
    var userID: String? {
        authenticationManager.userID
    }

    // MARK: - Constants
    let privatePolicyURLString: String = ContentConstants.ContentStrings.privatePolicyURL
    let termsAndConditionsURLString: String = ContentConstants.ContentStrings.termsAndConditionsURL
    let debounceMilliseconds: Int = 750

    // MARK: - Initialization
    init(authenticationManager: AnyAuthenticationManager, webViewService: WebViewService) {
        self.authenticationManager = authenticationManager
        self.webViewService = webViewService
        self.showWebView = webViewService.showWebView
        self.showWebViewAlert = webViewService.showAlert
        self.alertTitle = webViewService.alertTitle
        self.alertMessage = webViewService.alertMessage
        self.webViewURL = webViewService.webViewURL

        // Property observers for web view service.
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

        // Property observers for authentication manager.
        authenticationManager.$authenticationToast
            .assign(to: &$authenticationErrorToast)
    }
    
    // MARK: - Guest Methods
    /// Handles the guest login process.
    func continueWithoutAccount() async {
        await authenticationManager.continueWithoutAccount()
    }

    // MARK: - Email/Password Authentication Methods
    /// Handles the email sign-in process.
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
            reportError(error)
        }
    }
    
    /// Handles the email sign-up and sign-in process.
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
                reportError(signUpError)
                // If the error is due to email already in use, try signing in with the existing account.
                if signUpError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    do {
                        try await emailSignIn(email: signUpCredentials.email, password: signUpCredentials.password)
                    } catch {
                        setEmailErrorToast()
                        reportError(error)
                    }
                } else {
                    setEmailErrorToast()
                }
            }
        } else {
            setEmailErrorToast()
        }
    }
    
    /// Clears the authentication credentials and resets the view model state.
    func clearCredentials() {
        emailPasswordLoginCredentials = EmailPasswordLoginCredentials()
        signUpCredentials = EmailPasswordSignUpCredentials()
        confirmPassword = ""
    }
    
    /// Handles the email sign-in process.
    private func emailSignIn(email: String, password: String) async throws {
        try await authenticationManager.emailSignIn(email: email, password: password)
    }
    
    /// Sets the error toast for email sign-up errors.
    private func setEmailErrorToast() {
        emailErrorToast = Toast(
            style: .warning,
            message: "Email sign up failed. Please try again."
        )
    }

    // MARK: - Google Authentication Methods
    /// Handles the Google sign-in and sign-up process.
    func handleGoogleSignInAndSignUp() async throws {
        try await authenticationManager.signInWithGoogle()
    }

    // MARK: - Apple Authentication Methods
    /// Handles the Apple sign-in and sign-up process.
    func handleAppleSignInAndSignUp() async throws {
        try await authenticationManager.signInWithApple()
    }

    // MARK: - Password Management
    /// Sends a password reset email to the user.
    func sendPasswordResetEmail(email: String) async {
        do {
            try await authenticationManager.sendPasswordResetEmail(email: email)
        } catch {
            reportError(error)
        }
    }

    // MARK: - Validation Methods
    /// Sets up the validation for the login button.
    func setupLoginValidation() {
        // Combine the email and password fields and debounce the input.
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
    
    /// Sets up the validation for the sign-up button.
    func setupSignUpValidation() {
        // Combine the email, password, name, and legal agreement fields and debounce the input.
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
    
    /// Validates the email sign-up credentials.
    private func validateEmailSignUpCredentials() -> Bool {
        // Reset the sign up field errors.
        signUpFieldErrors.removeAll()
        
        // Validate the credentials using the UserValidator.
        if let error = UserValidator.validateIsNotEmpty(signUpCredentials.name, for: .name) {
            signUpFieldErrors[.name] = error
        }
        if let error = UserValidator.validateEmail(signUpCredentials.email) {
            signUpFieldErrors[.email] = error
        }
        if let error = UserValidator.validatePassword(signUpCredentials.password) {
            signUpFieldErrors[.password] = error
        }
        if let error = UserValidator.checkPasswordMatch(signUpCredentials.password, confirmPassword: confirmPassword) {
            signUpFieldErrors[.confirmPassword] = error
        }
        if let error = UserValidator.validateIsTrue(signUpCredentials.agreedToLegal, for: .agreedToLegal) {
            signUpFieldErrors[.agreedToLegal] = error
        }
        return signUpFieldErrors.isEmpty
    }

    // MARK: - Web View Management
    /// Loads the web view with the specified URL string and type.
    private func loadWebView(urlString: String, type: WebViewType) {
        webViewService.loadWebView(urlString: urlString, type: type)
    }
    
    /// Loads the privacy policy web view.
    func loadPrivacyPolicyWebView() {
        loadWebView(urlString: privatePolicyURLString, type: .privatePolicy)
        webViewType = .privatePolicy
    }
    
    /// Loads the terms and conditions web view.
    func loadTermsAndConditionsWebView() {
        loadWebView(urlString: termsAndConditionsURLString, type: .termsAndConditions)
        webViewType = .termsAndConditions
    }
    
    func handleWebViewError() {
        if let webViewType {
            webViewService.handleWebViewError(type: webViewType)
        }
    }
    
    func dismissWebView() {
        webViewService.dismissWebView()
    }
}
