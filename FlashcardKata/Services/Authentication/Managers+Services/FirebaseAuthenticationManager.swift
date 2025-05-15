//
//  FirebaseAuthenticationManager.swift
//  Created by Tammy Ho.
//
//  This class manages user authentication processes, including sign in, sign up, reauthentication, and sign out.
//  It supports multiple authentication providers (email/password, Google, Apple, guest) and integrates with Firebase Authentication.

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

/// A class that manages user authentication for sign in, sign up, and reauthentication processes.
@MainActor
final class FirebaseAuthenticationManager: NSObject, ObservableObject, AuthenticationManagerProtocol, AuthenticationManagerPublisherProtocol {
    // MARK: - Properties
    @AppStorage(UserDefaultsKeys.authenticationProvider) var authenticationProvider: AuthenticationProvider?

    @Published var errorMessage: String?
    @Published var authenticationState: AuthenticationState = .signedOut
    @Published var userID: String?
    @Published var authenticationToast: Toast?
    
    private let userProfileService = UserProfileService()
    private let googleAuthenticationService = GoogleAuthenticationService()
    
    var reauthenticationCompletion: ((OAuthCredential) -> Void)?
    private var currentNonce: String?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    // MARK: - Publishers
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
    
    // MARK: - Initializers
    override init() {
        super.init()
        addAuthStateListener() // Listen for auth state changes.

        // Set stored userID from Firebase is user is already logged in.
        if let currentUser = Auth.auth().currentUser {
            self.userID = currentUser.uid
        }
    }
    
    /// Removes the authentication state listener when the object is deinitialized.
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateListenerHandle = nil
        }
    }

    // MARK: - Auth State Listener
    /// Adds a listener to monitor authentication state changes.
    private func addAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.authenticationState = .signedIn
            } else {
                self?.authenticationState = .signedOut
            }

            if let userID = user?.uid {
                self?.userID = userID
            }
        }
    }

    // MARK: - Sign In / Sign Up Methods
    
    // Guest Sign In
    /// Signs in the user as a guest.
    func continueWithoutAccount() async {
        await setAuthenticationProvider(.guest)
        authenticationState = .guestUser
    }
    
    /// Gets the account creation date of the current user.
    func getAccountCreationDate() async throws -> Date? {
        guard let user = Auth.auth().currentUser else {
            reportError(AppError.systemError)
            return nil
        }
        return user.metadata.creationDate
    }
    
    /// Navigates to the sign-in screen and clears the user ID and authentication provider.
    func navigateToSignInWithoutAccount() {
        authenticationState = .signedOut
        removeUserID()
        removeAuthenticationProvider()
    }

    // Email-based sign in and sign up
    /// Signs in the user with email and password.
    func emailSignIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            await setAuthenticationProvider(.emailPassword)
        } catch {
            throw handleEmailAuthenticationNSError(error)
        }
    }

    /// Signs up the user with email and password.
    func emailSignUp(name: String, email: String, password: String) async throws {
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            var userProfile = UserProfile(user: authDataResult.user)
            userProfile.name = name
            try await userProfileService.createUserProfile(userProfile)
            await setAuthenticationProvider(.emailPassword)
        } catch {
            throw handleEmailAuthenticationNSError(error)
        }
    }

    // Google Sign In and Sign Up
    /// Signs in the user with Google authentication.
    func signInWithGoogle() async throws {
        try await googleAuthenticationService.signIn(authenticationManager: self)
    }

    // Apple Sign In and Sign Up
    /// Signs in the user with Apple authentication.
    private func appleSignInOrSignUp(tokens: AppleSignInResult) async throws {
        let credential = OAuthProvider.credential(
            withProviderID: AuthenticationProvider.apple.rawValue,
            idToken: tokens.token,
            rawNonce: tokens.nonce
        )

        let authDataResult = try await signIn(with: credential)
        await setAuthenticationProvider(.apple)

        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? false
        if isNewUser {
            try await userProfileService.createUserProfile(UserProfile(user: authDataResult.user))
        }
    }

    /// Initiates the Apple sign-in process.
    func signInWithApple() async throws {
        guard let topVC = TopViewControllerHelper.shared.topViewController() else {
            throw AppError.systemError
        }

        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        let presenter = AuthorizationControllerPresenter(viewController: topVC)
        authorizationController.presentationContextProvider = presenter
        authorizationController.performRequests()
    }

    /// Generates a random nonce string of the specified length, used for Apple authentication.
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

    /// Computes the SHA256 hash of the given string, used for Apple authentication.
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    // MARK: - Sign Out Methods
    /// Signs out the user from the current session, and removes stored user ID and authentication provider.
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            removeUserID()
            removeAuthenticationProvider()
        } catch {
            throw AppError.userAccountError("Unable to sign out. Please try again.")
        }
    }

    // MARK: - Reauthentication Methods
    /// Reauthenticates the user based on the selected authentication provider.
    func reauthenticateUser(
        email: String?,
        password: String?,
        completion: @escaping () async throws -> Void
    ) async throws {
        switch authenticationProvider {
        case .emailPassword:
            guard let email, let password else {
                throw AppError.userAccountError("Email and password are required.")
            }
            try await reauthenticateWithEmail(email: email, password: password)
            try await completion()
        case .google:
            try await reauthenticateWithGoogle()
            try await completion()
        case .apple:
            try await reauthenticateWithApple()
            try await completion()
        case .guest:
            return
        case nil:
            throw AppError.userAccountError("Authentication provider not found.")
        }
    }

    /// Reauthenticates the user with the specified email and password.
    private func reauthenticateWithEmail(email: String, password: String) async throws {
        do {
            guard let user = Auth.auth().currentUser else {
                throw AppError.userNotAuthenticated
            }
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            try await user.reauthenticate(with: credential)
        } catch {
            throw handleEmailAuthenticationNSError(error)
        }
    }

    /// Reauthenticates the user with Google authentication.
    private func reauthenticateWithGoogle() async throws {
        try await googleAuthenticationService.reauthenticate()
    }
    
    /// Reauthenticates the user with Apple authentication.
    private func reauthenticateWithApple() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppError.userNotAuthenticated
        }
        guard let topVC = TopViewControllerHelper.shared.topViewController() else {
            throw AppError.systemError
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
                    throw AppError.userAccountError("Unable to reauthenticate.")
                }
            }
        }
        authorizationController.delegate = self
        let presenter = AuthorizationControllerPresenter(viewController: topVC)
        authorizationController.presentationContextProvider = presenter
        authorizationController.performRequests()
    }

    // MARK: - Authentication Fields Management
    /// Sends a password reset email to the specified email address.
    func sendPasswordResetEmail(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw handleEmailAuthenticationNSError(error)
        }
    }

    /// Updates the user's email address and sends a verification email.
    func updateUserEmail(newEmail: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppError.userNotAuthenticated
        }
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)

        do {
            try await user.reauthenticate(with: credential)
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        } catch {
            throw AppError.systemError
        }
    }

    /// Syncs the user's email address with their user profile.
    func syncUserEmailWithUserProfile() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppError.userNotAuthenticated
        }

        if let userProfile = try await fetchUserProfile(id: user.uid),
            let currentEmail = user.email,
            userProfile.email != currentEmail {
            
            var updatedUserProfile = userProfile
            updatedUserProfile.email = currentEmail
            try await updateUserProfile(updatedUserProfile)
        }
    }

    /// Deletes the user's account and removes the stored user ID and authentication provider.
    func deleteUser() async throws {
        do {
            guard let user = await getAuthenticatedUser() else {
                throw AppError.userNotAuthenticated
            }
            try await user.delete()
            removeUserID()
            removeAuthenticationProvider()
            authenticationState = .signedOut
        } catch {
            throw AppError.userAccountError("Unable to delete user account.")
        }
    }

    // MARK: - User Management
    /// Removes the stored user ID.
    private func removeUserID() {
        userID = nil
    }

    /// Stores the authentication provider.
    func setAuthenticationProvider(_ authenticationProvider: AuthenticationProvider) async {
        self.authenticationProvider = authenticationProvider
    }

    /// Removes the stored authentication provider.
    private func removeAuthenticationProvider() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.authenticationProvider)
    }

    // MARK: - User Profile Methods
    /// Creates a new user profile based on the provided user.
    func createUserProfile(user: User) async throws {
        try await userProfileService.createUserProfile(UserProfile(user: user))
    }
    
    /// Fetches the user profile for the current user.
    func fetchUserProfile(id: String) async throws -> UserProfile? {
        return try await userProfileService.fetchUserProfile(id: id)
    }

    /// Updates the user profile with the new user profile.
    func updateUserProfile(_ userProfile: UserProfile) async throws {
        try await userProfileService.updateUserProfile(userProfile)
    }

    /// Deletes the user profile for the specified user ID.
    func deleteUserProfile(userID: String) async throws {
        try await userProfileService.deleteUserProfile(id: userID)
    }

    // MARK: - General Utility Methods
    /// Gets the current authenticated user.
    private func getAuthenticatedUser() async -> User? {
        return Auth.auth().currentUser
    }

    /// Checks if the user is authenticated.
    func handleAppResume() async {
        guard Auth.auth().currentUser != nil else {
            authenticationState = .signedOut
            removeAuthenticationProvider()
            removeUserID()
            return
        }
        authenticationState = .signedIn
    }
    
    /// Signs in the user for the provided credential (Apple, Google, etc.) using Firebase authentication.
    func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().signIn(with: credential)
        } catch {
            throw AppError.userAccountError("We couldn't sign you in. Please try again.")
        }
    }
    
    // MARK: - Error Handling
    /// Maps Firebase Authentication errors to AppError
    func handleEmailAuthenticationNSError(_ error: Error) -> AppError {
        // Convert the error to NSError to get the error code
        let nsError = error as NSError
        
        // Check if the error is a Firebase Authentication error
        if let _ = AuthErrorCode.Code(rawValue: nsError.code) {
            // Handle Firebase Authentication errors
            let authError = AuthErrorCode(_nsError: nsError)
            return handleEmailAuthenticationError(authError)
        } else {
            // Return a system error for non-Firebase Authentication errors
            return .systemError
        }
    }
    
    /// Maps Firebase Authentication errors to AppError
    private func handleEmailAuthenticationError(_ error: AuthErrorCode) -> AppError {
        switch error.code {
        case .networkError:
            return .networkError
        case .wrongPassword:
            return .userAccountError("Incorrect password. Please try again.")
        case .invalidEmail:
            return .userAccountError("Invalid email address. Please enter a valid email.")
        case .emailAlreadyInUse:
            return .userAccountError("Email address is already in use.")
        case .userNotFound:
            return .userAccountError("No account found for this email address. Please sign up to continue.")
        default:
            return .systemError
        }
    }
}

// MARK: - Apple Sign In Delegate Methods
@MainActor
extension FirebaseAuthenticationManager: ASAuthorizationControllerDelegate {
    /// Handles the completion of the Apple sign-in process.
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
          let appleIDToken = appleIDCredential.identityToken,
          let idTokenString = String(data: appleIDToken, encoding: .utf8),
          let nonce = currentNonce else {
            return
        }

        let tokens = AppleSignInResult(token: idTokenString, nonce: nonce)

        if let reauthenticationCompletion {
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            reauthenticationCompletion(credential)
            self.reauthenticationCompletion = nil
        } else {
            Task {
                do {
                    try await appleSignInOrSignUp(tokens: tokens)
                } catch {
                    authenticationToast = Toast(style: .error, message: "Unable to complete authentication.")
                    reportError(error)
                }
            }
        }
    }
    
    /// Handles the failure of the Apple sign-in process.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        authenticationToast = Toast(style: .error, message: "Unable to complete authentication.")
    }
}

/// A class that presents the authorization controller for Apple sign-in.
@MainActor
extension FirebaseAuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    /// Provides the presentation anchor for the authorization controller.
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let topVC = TopViewControllerHelper.shared.topViewController() else {
            return ASPresentationAnchor()
        }
        return topVC.view.window ?? ASPresentationAnchor()
    }
}
