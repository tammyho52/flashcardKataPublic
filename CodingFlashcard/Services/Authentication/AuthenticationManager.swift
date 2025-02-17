//
//  AuthenticationManager.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

@MainActor
final class AuthenticationManager: NSObject, ObservableObject {
    // MARK: - Dependencies
    @Environment(\.dismiss) var dismiss
    @AppStorage(UserDefaultsKeys.authenticationProvider) private var authenticationProvider: AuthenticationProvider?
    
    // MARK: - UI State Management
    @Published var errorMessage: String?
    @Published var isAuthenticating: Bool = false
    @Published var didSignInWithApple: Bool = false
    
    // MARK: - Constants and Helpers
    let googleSignInHelper: GoogleSignInHelper = GoogleSignInHelper()
    let userProfileManager = UserProfileService()
    
    private var currentNonce: String?
    
    @Published var authenticationState: AuthenticationState = .signedOut
    @Published var storedUserID: String?
    @Published var authenticationToast: Toast?
    @Published var isReauthenticating: Bool = false
    
    var userID: String {
        storedUserID ?? ""
    }
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    override init() {
        super.init()
        addAuthStateListener()
        
        if let currentUser = Auth.auth().currentUser {
            self.storedUserID = currentUser.uid
        }
    }

    private func addAuthStateListener() {
        
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if user != nil {
                self?.authenticationState = .signedIn
            } else {
                self?.authenticationState = .signedOut
            }
            
            if let userID = user?.uid {
                self?.storedUserID = userID
            } else {
                self?.storedUserID = nil
            }
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateListenerHandle = nil
        }
    }
    
    // MARK: - Sign In / Sign Up Methods
    
    func continueWithoutAccount() async {
        await setAuthenticationProvider(.guest)
        authenticationState = .guestUser
    }
    
    func navigateToSignInWithoutAccount() {
        authenticationState = .signedOut
        removeUserID()
        removeAuthenticationProvider()
    }
    
    func emailSignIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
        await setAuthenticationProvider(.emailPassword)
    }
    
    func emailSignUp(name: String, email: String, password: String) async throws {
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            var userProfile = UserProfile(user: authDataResult.user)
            userProfile.name = name
            try await userProfileManager.createUserProfile(userProfile)
            await setAuthenticationProvider(.emailPassword)
        } catch {
            throw error
        }
    }
    
    /// Google Sign Up
    func signInWithGoogle() async {
        do {
            let result = try await googleSignInHelper.getCredential()
            let credential = result.credential
            let authDataResult = try await Auth.auth().signIn(with: credential)
            await setAuthenticationProvider(.google)
            
            let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? false
            if isNewUser {
                try await userProfileManager.createUserProfile(UserProfile(user: authDataResult.user))
            }
        } catch {
            authenticationToast = Toast(style: .error, message: "Unable to complete authentication.")
        }
    }
    
    /// Apple Sign Up
    private func appleSignInOrSignUp(tokens: SignInWithAppleResult) async throws {
        let credential = OAuthProvider.credential(
            withProviderID: AuthenticationProvider.apple.rawValue,
            idToken: tokens.token,
            rawNonce: tokens.nonce
        )
        
        let authDataResult = try await Auth.auth().signIn(with: credential)
        await setAuthenticationProvider(.apple)
        
        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? false
        if isNewUser {
            try await userProfileManager.createUserProfile(UserProfile(user: authDataResult.user))
        }
    }
    
    func signInWithApple() async {
        guard let topVC = TopViewControllerHelper.shared.topViewController() else { return }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    // MARK: - Sign Out Methods
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            removeUserID()
            removeAuthenticationProvider()
        } catch {
            throw error
        }
    }
    
    // MARK: - Reauthenticate Methods
    
    func reauthenticateUser(email: String?, password: String?, completion: @escaping () async throws -> Void) async throws {
        switch authenticationProvider {
        case .emailPassword:
            do {
                guard let email, let password else { throw AuthenticationError.missingCredentials }
                try await reauthenticateWithEmail(email: email, password: password)
                try await completion()
            } catch {
                throw error
            }
        case .google:
            do {
                try await reauthenticateWithGoogle()
                try await completion()
            } catch {
                throw error
            }
        case .apple:
            do {
                try await reauthenticateWithApple()
                try await completion()
            } catch {
                throw error
            }
        case .guest:
            return
        case nil:
            throw AuthenticationError.unknownAuthenticationMode
        }
    }
  
    private func reauthenticateWithEmail(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else { throw AuthenticationError.userNotAuthenticated }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
    
    private func reauthenticateWithGoogle() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthenticationError.userNotAuthenticated }
        let result = try await googleSignInHelper.getCredential()
        try await user.reauthenticate(with: result.credential)
    }
    
    var reauthenticationCompletion: ((OAuthCredential) -> Void)?
    
    private func reauthenticateWithApple() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthenticationError.userNotAuthenticated }
        guard let topVC = TopViewControllerHelper.shared.topViewController() else {
            throw AuthenticationError.unknownAuthenticationMode
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        reauthenticationCompletion = { credential in
            Task {
                do {
                    try await user.reauthenticate(with: credential)
                } catch {
                    throw error
                }
            }
        }
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
    
    
    // MARK: - Authentication Fields Management
    
    func sendPasswordResetEmail(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updateUserEmail(newEmail: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else { throw AuthenticationError.userNotAuthenticated }
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
        
        do {
            try await user.reauthenticate(with: credential)
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        } catch {
            throw error
        }
    }
    
    func syncUserEmailWithUserProfile() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthenticationError.userNotAuthenticated }

        if let userProfile = try await fetchUserProfile(id: user.uid), let currentEmail = user.email, userProfile.email != currentEmail {
            var updatedUserProfile = userProfile
            updatedUserProfile.email = currentEmail
            try await updateUserProfile(userProfile: updatedUserProfile)
        }
    }
    
    func deleteUser() async throws {
        guard let user = await getAuthenticatedUser() else {
            throw URLError(.badURL)
        }
        try await user.delete()
        removeUserID()
        removeAuthenticationProvider()
        authenticationState = .signedOut
    }
    
    // MARK: - User ID Management
    
    private func removeUserID() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userID)
    }
    
    private func setAuthenticationProvider(_ authenticationProvider: AuthenticationProvider) async {
        self.authenticationProvider = authenticationProvider
    }
    
    private func removeAuthenticationProvider() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.authenticationProvider)
    }
    
    // MARK: - User Profile Methods
    func createNewUser(user: User) async throws {
        try await userProfileManager.createUserProfile(UserProfile(user: user))
    }
    
    func fetchUserProfile(id: String) async throws -> UserProfile? {
        return try await userProfileManager.fetchUserProfile(id: id)
    }
    
    func updateUserProfile(userProfile: UserProfile) async throws {
        try await userProfileManager.updateUserProfile(userProfile: userProfile)
    }
    
    func deleteUserProfile(userID: String) async throws {
        try await userProfileManager.deleteUserProfile(id: userID)
    }
    
    // MARK: - General Utility Methods

    func getAuthenticatedUser() async -> User? {
        return Auth.auth().currentUser
    }
    
    func setAuthenticationProvider(for providerID: String) {
        switch providerID {
        case "google.com":
            authenticationProvider = .google
        case "apple.com":
            authenticationProvider = .apple
        case "password":
            authenticationProvider = .emailPassword
        default:
            return
        }
    }
    
    func handleAppResume() async {
        guard let _ = Auth.auth().currentUser else {
            authenticationState = .signedOut
            removeAuthenticationProvider()
            removeUserID()
            return
        }
        authenticationState = .signedIn
    }
    
    func refreshUserToken(user: User) {
        user.getIDTokenForcingRefresh(true)
    }
}

struct SignInWithAppleResult {
    let token: String
    let nonce: String
}

extension AuthenticationManager: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard
          let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let appleIDToken = appleIDCredential.identityToken,
          let idTokenString = String(data: appleIDToken, encoding: .utf8),
          let nonce = currentNonce else {
            return
        }
        
        let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce)
        
        if let reauthenticationCompletion {
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            reauthenticationCompletion(credential)
            self.reauthenticationCompletion = nil
        } else {
            Task {
                do {
                    try await appleSignInOrSignUp(tokens: tokens)
                } catch {
                    authenticationToast = Toast(style: .error, message: "Unable to complete authentication.")
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      
    }
  
}

extension UIViewController: @retroactive ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
