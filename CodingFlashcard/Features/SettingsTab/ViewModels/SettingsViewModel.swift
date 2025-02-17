//
//  SettingsViewModel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage(UserDefaultsKeys.authenticationProvider) var authenticationProvider: AuthenticationProvider?
    @ObservedObject var webViewService: WebViewService
    @ObservedObject var authenticationManager: AuthenticationManager
   
    @Published private(set) var user: UserProfile? = nil
    @Published var showWebView: Bool
    @Published var showWebViewAlert: Bool
    
    private var databaseManager: DatabaseManagerProtocol
    
    init(authenticationManager: AuthenticationManager, databaseManager: DatabaseManagerProtocol, webViewService: WebViewService) {
        self.authenticationManager = authenticationManager
        self.databaseManager = databaseManager
        self.webViewService = webViewService
        self.showWebView = webViewService.showWebView
        self.showWebViewAlert = webViewService.showAlert
       
        webViewService.$showWebView
            .assign(to: &$showWebView)
        webViewService.$showAlert
            .assign(to: &$showWebViewAlert)
    }
    
    // MARK: - Guest Methods
    func isGuestUser() -> Bool {
        databaseManager.isGuestUser()
    }
    
    func navigateToSignInWithoutAccount() {
        databaseManager.navigateToSignInWithoutAccount()
    }
    
    // MARK: - Settings Methods
    var alertTitle: String {
        webViewService.alertTitle
    }
    
    var alertMessage: String {
        webViewService.alertMessage
    }
    
    var webViewURL: URL? {
        webViewService.webViewURL
    }
   
    func loadWebView(urlString: String, type: WebViewType) {
        webViewService.loadWebView(urlString: urlString, type: type)
    }
    
    func handleWebViewError(type: WebViewType) {
        webViewService.handleWebViewError(type: type)
    }
    
    func dismissWebView() {
        webViewService.dismissWebView()
    }
    
    func signOut() async throws {
        try await authenticationManager.signOut()
    }
    
    func sendPasswordResetEmail(email: String) async {
        do {
            try await authenticationManager.sendPasswordResetEmail(email: email)
        } catch {
            
        }
    }
    
    func deleteUserData() async throws {
        try await databaseManager.deleteAllUserData()
        try await authenticationManager.deleteUserProfile(userID: authenticationManager.userID)
    }
    
    func deleteUser() async throws {
        try await authenticationManager.deleteUser()
    }
    
    func reauthenticateUser(email: String?, password: String?, completion: @escaping () async throws -> Void) async throws {
        try await authenticationManager.reauthenticateUser(email: email, password: password, completion: completion)
    }
    
    func updateUserEmail(newEmail: String, password: String) async throws {
        try await authenticationManager.updateUserEmail(newEmail: newEmail, password: password)
    }
}
