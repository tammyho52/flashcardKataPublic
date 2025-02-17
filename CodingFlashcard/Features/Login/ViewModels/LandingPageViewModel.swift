//
//  LandingPageViewModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import Combine
import SwiftUI
import AuthenticationServices
import CryptoKit

@MainActor
final class LandingPageViewModel: ObservableObject {
    
    // MARK: - Dependencies
    @AppStorage(UserDefaultsKeys.authenticationProvider) var authenticationProvider: AuthenticationProvider?
    @ObservedObject var webViewService: WebViewService
    
    // MARK: - Authentication State
    
    @Published var emailPasswordLoginCredentials: EmailPasswordLoginCredentials = EmailPasswordLoginCredentials()
    @Published var signUpCredentials: SignUpCredentials = SignUpCredentials()
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
    
    // MARK: - Initialization
    
    init(authenticationManager: AuthenticationManager, webViewService: WebViewService) {
        self.authenticationManager = authenticationManager
        self.webViewService = webViewService
        self.showWebView = webViewService.showWebView
        self.showWebViewAlert = webViewService.showAlert
        self.alertTitle = webViewService.alertTitle
        self.alertMessage = webViewService.alertMessage
        self.webViewURL = webViewService.webViewURL
        
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
        
        authenticationManager.$authenticationToast
            .assign(to: &$authenticationErrorToast)
    }
    
    func clearCredentials() {
        emailPasswordLoginCredentials = EmailPasswordLoginCredentials()
        signUpCredentials = SignUpCredentials()
        confirmPassword = ""
    }
    
    //MARK: - Guest Methods
    func continueWithoutAccount() async {
        await authenticationManager.continueWithoutAccount()
    }
    
    // MARK: - Email/Password Authentication Methods
    
    private func emailSignIn(email: String, password: String) async throws {
        try await authenticationManager.emailSignIn(email: email, password: password)
    }
    
    func emailSignIn() async {
        do {
            try await emailSignIn(email: emailPasswordLoginCredentials.email, password: emailPasswordLoginCredentials.password)
            try await authenticationManager.syncUserEmailWithUserProfile()
            clearCredentials()
        } catch {
            emailErrorToast = Toast(style: .error, message: "Email Sign in failed. Please check your credentials.")
        }
    }
    
    func emailSignUpAndSignIn() async {
        if validateEmailSignUpCredentials() {
            do {
                try await authenticationManager.emailSignUp(name: signUpCredentials.name, email: signUpCredentials.email, password: signUpCredentials.password)
                clearCredentials()
            } catch let signUpError as NSError {
                if signUpError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    do {
                        try await emailSignIn(email: signUpCredentials.email, password: signUpCredentials.password)
                    } catch {
                        emailErrorToast = Toast(style: .warning, message: "Email is already in use. Please try logging in.")
                    }
                } else {
                    emailErrorToast = Toast(style: .warning, message: "Email sign up failed. Please try again.")
                }
            }
        }
        emailErrorToast = Toast(style: .warning, message: "Email sign up failed. Please try again.")
    }
    
    // MARK: - Google Authentication Methods
    
    func handleGoogleSignInAndSignUp() async throws {
        await authenticationManager.signInWithGoogle()
    }
    
    // MARK: - Apple Authentication Methods
    func handleAppleSignInAndSignUp() async throws {
        await authenticationManager.signInWithApple()
    }
    
    // MARK: - Password Management
    func sendPasswordResetEmail(email: String) async {
        do {
            try await authenticationManager.sendPasswordResetEmail(email: email)
        } catch {
            
        }
    }
    
    // MARK: - Validation Methods
    
    func setupLoginValidation() {
        Publishers.CombineLatest(
            $emailPasswordLoginCredentials.map(\.email),
            $emailPasswordLoginCredentials.map(\.password)
        )
        .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
        .map { email, password in
            let isEmailInvalid = email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let isPasswordInvalid = password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return isEmailInvalid || isPasswordInvalid
        }
        .assign(to: &$isLoginButtonDisabled)
    }
    
    func setupSignUpValidation() {
        Publishers.CombineLatest4(
            $signUpCredentials.map(\.email),
            $signUpCredentials.map(\.password),
            $signUpCredentials.map(\.name),
            $signUpCredentials.map(\.agreedToLegal)
        )
        .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
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
    
    func loadPrivacyPolicyWebView() {
        loadWebView(urlString: privatePolicyURLString, type: .privatePolicy)
        webViewType = .privatePolicy
    }
    
    func loadTermsAndConditionsWebView() {
        loadWebView(urlString: termsAndConditionsURLString, type: .termsAndConditons)
        webViewType = .termsAndConditons
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

