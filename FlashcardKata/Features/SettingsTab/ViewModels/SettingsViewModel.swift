//
//  SettingsViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This view model manages the Settings tab, handling user authentication, legal agreements, and user data management.

import SwiftUI

/// A view model for the Settings tab.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Properties
    @AppStorage(UserDefaultsKeys.authenticationProvider) var authenticationProvider: AuthenticationProvider?
    @ObservedObject var webViewService: WebViewService

    @Published private(set) var user: UserProfile?
    @Published var showWebView: Bool
    @Published var showWebViewAlert: Bool

    private var databaseManager: DatabaseManagerProtocol
    private var authenticationManager: any AuthenticationManagerProtocol

    // MARK: - Initializer
    init(
        authenticationManager: any AuthenticationManagerProtocol,
        databaseManager: DatabaseManagerProtocol,
        webViewService: WebViewService
    ) {
        self.authenticationManager = authenticationManager
        self.databaseManager = databaseManager
        self.webViewService = webViewService
        self.showWebView = webViewService.showWebView
        self.showWebViewAlert = webViewService.showAlert
        
        // Observe changes to the web view service's properties
        webViewService.$showWebView
            .assign(to: &$showWebView)
        webViewService.$showAlert
            .assign(to: &$showWebViewAlert)
    }

    // MARK: - Guest Methods
    /// Check if the user is a guest
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }

    /// Navigate to the sign-in screen for users without an account
    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }

    // MARK: - Web View Methods
    var alertTitle: String {
        webViewService.alertTitle
    }

    var alertMessage: String {
        webViewService.alertMessage
    }

    var webViewURL: URL? {
        webViewService.webViewURL
    }

    /// Load a web view with the specified URL and type
    func loadWebView(urlString: String, type: WebViewType) {
        webViewService.loadWebView(urlString: urlString, type: type)
    }

    /// Handle web view error based on the type
    func handleWebViewError(type: WebViewType) {
        webViewService.handleWebViewError(type: type)
    }

    func dismissWebView() {
        webViewService.dismissWebView()
    }

    // MARK: - User Authentication / Data Management Methods
    func signOut() async throws {
        try await authenticationManager.signOut()
    }

    func sendPasswordResetEmail(email: String) async throws {
        try await authenticationManager.sendPasswordResetEmail(email: email)
    }

    /// Delete all user data and user profile
    func deleteUserData() async throws {
        guard let userID = authenticationManager.userID else {
            throw AppError.userNotAuthenticated
        }
        
        try await databaseManager.deleteAllUserData()
        try await authenticationManager.deleteUserProfile(userID: userID)
    }

    /// Delete user from the authentication system
    func deleteUser() async throws {
        try await authenticationManager.deleteUser()
    }

    /// Reauthenticate the user with email and password
    func reauthenticateUser(
        email: String?,
        password: String?,
        completion: @escaping () async throws -> Void
    ) async throws {
        try await authenticationManager.reauthenticateUser(
            email: email,
            password: password,
            completion: completion
        )
    }

    /// Update user email with new email and password
    func updateUserEmail(newEmail: String, password: String) async throws {
        try await authenticationManager.updateUserEmail(newEmail: newEmail, password: password)
    }
}
