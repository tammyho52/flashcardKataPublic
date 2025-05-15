//
//  MockFirebaseAuthenticationManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Mock implementation of Firebase Authentication Manager for testing purposes.

import Foundation
import FirebaseAuth
import SwiftUI

@MainActor
class MockFirebaseAuthenticationManager: NSObject, ObservableObject, AuthenticationManagerProtocol, AuthenticationManagerPublisherProtocol {
    @AppStorage(UserDefaultsKeys.authenticationProvider) var authenticationProvider: AuthenticationProvider?
    @Published var errorMessage: String?
    @Published var authenticationState: AuthenticationState = .signedOut // Default to signed in for mock
    @Published var userID: String? = "testUserID" // Default to test user ID for mock
    @Published var authenticationToast: Toast?
    
    // Published properties for Combine publishers.
    var errorMessagePublisher: Published<String?>.Publisher {
        $errorMessage
    }
    var authenticationStatePublisher: Published<AuthenticationState>.Publisher {
        $authenticationState
    }
    var userIDPublisher: Published<String?>.Publisher {
        $userID
    }
    var authenticationToastPublisher: Published<Toast?>.Publisher {
        $authenticationToast
    }
    
    override init() {
        super.init()
        
        // Initialize the authentication provider to logged in
        Task {
            await setAuthenticationProvider(.emailPassword)
            authenticationState = .signedIn
        }
    }
    
    private let testUserID = "testUserID"
    
    func continueWithoutAccount() async {
        await setAuthenticationProvider(.guest)
        self.authenticationState = .guestUser
    }
    
    func navigateToSignInWithoutAccount() {
        authenticationState = .signedOut
    }
    
    func getAccountCreationDate() async throws -> Date? {
        return Date()
    }
    
    func emailSignIn(email: String, password: String) async throws {
        authenticationState = .signedIn
        await setAuthenticationProvider(.emailPassword)
    }
    
    func emailSignUp(name: String, email: String, password: String) async throws {
        authenticationState = .signedIn
        userID = testUserID
        // Skip creating a user profile in mock
    }
    
    func signInWithGoogle() async throws {
        authenticationState = .signedIn
        userID = testUserID
        // Skip creating a user profile in mock
    }
    
    func signInWithApple() async throws {
        authenticationState = .signedIn
        userID = testUserID
        // Skip creating a user profile in mock
    }
    
    func signOut() async throws {
        authenticationState = .signedOut
        userID = nil
    }
    
    func reauthenticateUser(email: String?, password: String?, completion: @escaping () async throws -> Void) async throws {
        try await completion()
    }
    
    func sendPasswordResetEmail(email: String) async throws {
        // No-op in mock
    }
    
    func updateUserEmail(newEmail: String, password: String) async throws {
        // No-op in mock
    }
    
    func syncUserEmailWithUserProfile() async throws {
        // Skip mock implementation of user profile sync
        print("sync user email with user profile")
    }
    
    func deleteUser() async throws {
        userID = nil
        authenticationState = .signedOut
    }
    
    func createUserProfile(user: User) async throws {
        // No-op in mock
    }
    
    func fetchUserProfile(id: String) async throws -> UserProfile? {
        // No-op in mock
        return nil
    }
    
    func updateUserProfile(_ userProfile: UserProfile) async throws {
        // No-op in mock
    }
    
    func deleteUserProfile(userID: String) async throws {
        // No-op in mock
    }
    
    func setAuthenticationProvider(_ authenticationProvider: AuthenticationProvider) async {
        self.authenticationProvider = authenticationProvider
    }
    
    func handleAppResume() async {
        // Assumes the user is still signed in
        authenticationState = .signedIn
    }
    
    private func removeAuthenticationProvider() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.authenticationProvider)
    }
    
    func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        // No-op in mock, just default to throwing an error
        throw AppError.systemError
    }
    
    func handleEmailAuthenticationNSError(_ error: Error) -> AppError {
        return AppError.systemError
    }
}
