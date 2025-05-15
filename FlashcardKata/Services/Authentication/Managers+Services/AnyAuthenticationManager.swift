//
//  AnyAuthenticationManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class wraps any authentication manager that conforms to the AuthenticationManagerProtocol.

import SwiftUI
import Combine
import FirebaseAuth

/// A type-erased wrapper for any authentication manager that conforms to the AuthenticationManagerProtocol. This allows decoupling database managers from the concrete implementation.
@MainActor
class AnyAuthenticationManager: NSObject, ObservableObject, AuthenticationManagerProtocol {
    // MARK: - Properties
    @Published var errorMessage: String?
    @Published var authenticationState: AuthenticationState = .signedOut
    @Published var userID: String?
    @Published var authenticationToast: Toast?
    
    // MARK: - Private Properties
    // These closures are used to forward calls to the wrapped authentication manager
    private let _continueWithoutAccount: () async -> Void
    private let _navigateToSignInWithoutAccount: () -> Void
    private let _getAccountCreationDate: () async throws -> Date?
    private let _emailSignIn: (String, String) async throws -> Void
    private let _emailSignUp: (String, String, String) async throws -> Void
    private let _signInWithGoogle: () async throws -> Void
    private let _signInWithApple: () async throws -> Void
    private let _signOut: () async throws -> Void
    private let _reauthenticateUser: (String?, String?, @escaping () async throws -> Void) async throws -> Void
    private let _sendPasswordResetEmail: (String) async throws -> Void
    private let _updateUserEmail: (String, String) async throws -> Void
    private let _syncUserEmailWithUserProfile: () async throws -> Void
    private let _deleteUser: () async throws -> Void
    private let _handleAppResume: () async -> Void
    private let _signIn: (AuthCredential) async throws -> AuthDataResult
    private let _handleEmailAuthenticationNSError: (any Error) -> AppError

    private let _createUserProfile: (User) async throws -> Void
    private let _fetchUserProfile: (String) async throws -> UserProfile?
    private let _updateUserProfile: (UserProfile) async throws -> Void
    private let _deleteUserProfile: (String) async throws -> Void

    private let _setAuthenticationProvider: (AuthenticationProvider) async -> Void
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init<T: AuthenticationManagerProtocol & AuthenticationManagerPublisherProtocol & ObservableObject & NSObject>(
        authenticationManager: T
    ) {
        // The closures are capturing the methods of the authentication manager
        self._continueWithoutAccount = { await authenticationManager.continueWithoutAccount() }
        self._navigateToSignInWithoutAccount = { authenticationManager.navigateToSignInWithoutAccount() }
        self._getAccountCreationDate = { try await authenticationManager.getAccountCreationDate() }
        self._emailSignIn = { email, password in try await authenticationManager.emailSignIn(email: email, password: password) }
        self._emailSignUp = { name, email, password in try await authenticationManager.emailSignUp(name: name, email: email, password: password) }
        self._signInWithGoogle = { try await authenticationManager.signInWithGoogle() }
        self._signInWithApple = { try await authenticationManager.signInWithApple() }
        self._signOut = { try await authenticationManager.signOut() }
        self._reauthenticateUser = { email, password, completion in
            try await authenticationManager.reauthenticateUser(email: email, password: password, completion: completion)
        }
        self._sendPasswordResetEmail = { email in try await authenticationManager.sendPasswordResetEmail(email: email) }
        self._updateUserEmail = { newEmail, password in try await authenticationManager.updateUserEmail(newEmail: newEmail, password: password) }
        self._syncUserEmailWithUserProfile = { try await authenticationManager.syncUserEmailWithUserProfile() }
        self._deleteUser = { try await authenticationManager.deleteUser() }
        self._handleAppResume = { await authenticationManager.handleAppResume() }
        self._signIn = { credential in try await authenticationManager.signIn(with: credential) }
        self._handleEmailAuthenticationNSError = { error in authenticationManager.handleEmailAuthenticationNSError(error) }
        self._createUserProfile = { user in try await authenticationManager.createUserProfile(user: user) }
        self._fetchUserProfile = { id in try await authenticationManager.fetchUserProfile(id: id) }
        self._updateUserProfile = { userProfile in try await authenticationManager.updateUserProfile(userProfile) }
        self._deleteUserProfile = { userID in try await authenticationManager.deleteUserProfile(userID: userID) }
        self._setAuthenticationProvider = { authenticationProvider in
            await authenticationManager.setAuthenticationProvider(authenticationProvider)
        }
        
        super.init()
        
        // Subscribe to the authentication manager's publishers
        authenticationManager.errorMessagePublisher
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            .store(in: &cancellables)
        
        authenticationManager.authenticationStatePublisher
            .sink { [weak self] authenticationState in
                self?.authenticationState = authenticationState
            }
            .store(in: &cancellables)
        
        authenticationManager.userIDPublisher
            .sink { [weak self] userID in
                self?.userID = userID
            }
            .store(in: &cancellables)
        
        authenticationManager.authenticationToastPublisher
            .sink { [weak self] authenticationToast in
                self?.authenticationToast = authenticationToast
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Forwarded Methods
    func continueWithoutAccount() async {
        await _continueWithoutAccount()
    }
    
    func navigateToSignInWithoutAccount() {
        _navigateToSignInWithoutAccount()
    }
    
    func getAccountCreationDate() async throws -> Date? {
        try await _getAccountCreationDate()
    }
    
    func emailSignIn(email: String, password: String) async throws {
        try await _emailSignIn(email, password)
    }
    
    func emailSignUp(name: String, email: String, password: String) async throws {
        try await _emailSignUp(name, email, password)
    }
    
    func signInWithGoogle() async throws {
        try await _signInWithGoogle()
    }
    
    func signInWithApple() async throws {
        try await _signInWithApple()
    }
    
    func signOut() async throws {
        try await _signOut()
    }
    
    func reauthenticateUser(email: String?, password: String?, completion: @escaping () async throws -> Void) async throws {
        try await _reauthenticateUser(email, password, completion)
    }
    
    func sendPasswordResetEmail(email: String) async throws {
        try await _sendPasswordResetEmail(email)
    }
    
    func updateUserEmail(newEmail: String, password: String) async throws {
        try await _updateUserEmail(newEmail, password)
    }
    
    func syncUserEmailWithUserProfile() async throws {
        try await _syncUserEmailWithUserProfile()
    }
    
    func deleteUser() async throws {
        try await _deleteUser()
    }
    
    func handleAppResume() async {
        await _handleAppResume()
    }
    
    func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        try await _signIn(credential)
    }
    
    func handleEmailAuthenticationNSError(_ error: any Error) -> AppError {
        _handleEmailAuthenticationNSError(error)
    }
    
    func createUserProfile(user: User) async throws {
        try await _createUserProfile(user)
    }
    
    func fetchUserProfile(id: String) async throws -> UserProfile? {
        try await _fetchUserProfile(id)
    }
    
    func updateUserProfile(_ userProfile: UserProfile) async throws {
        try await _updateUserProfile(userProfile)
    }
    
    func deleteUserProfile(userID: String) async throws {
        try await _deleteUserProfile(userID)
    }
    
    func setAuthenticationProvider(_ authenticationProvider: AuthenticationProvider) async {
        await _setAuthenticationProvider(authenticationProvider)
    }
}
