//
//  AuthenticationManagerProtocol.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Protocol for managing user authentication and profile.

import Foundation
import FirebaseAuth

@MainActor
protocol AuthenticationManagerProtocol: ObservableObject, AnyObject {
    var errorMessage: String? { get set }
    var authenticationState: AuthenticationState { get set }
    var userID: String? { get set }
    var authenticationToast: Toast? { get set }
    
    func continueWithoutAccount() async
    func navigateToSignInWithoutAccount()
    func getAccountCreationDate() async throws -> Date?
    func emailSignIn(email: String, password: String) async throws
    func emailSignUp(name: String, email: String, password: String) async throws
    func signInWithGoogle() async throws
    func signInWithApple() async throws
    func signOut() async throws
    func reauthenticateUser(email: String?, password: String?, completion: @escaping () async throws -> Void) async throws
    func sendPasswordResetEmail(email: String) async throws
    func updateUserEmail(newEmail: String, password: String) async throws
    func syncUserEmailWithUserProfile() async throws
    func deleteUser() async throws
    func createUserProfile(user: User) async throws
    func fetchUserProfile(id: String) async throws -> UserProfile?
    func updateUserProfile(_ userProfile: UserProfile) async throws
    func deleteUserProfile(userID: String) async throws
    func setAuthenticationProvider(_ authenticationProvider: AuthenticationProvider) async
    func handleAppResume() async
    func signIn(with credential: AuthCredential) async throws -> AuthDataResult
    func handleEmailAuthenticationNSError(_ error: Error) -> AppError
}
