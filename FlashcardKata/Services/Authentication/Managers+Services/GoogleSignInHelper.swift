//
//  GoogleSignInHelper.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Helper class to facilitate Google sign in integration with Firebase.

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth

@MainActor
final class GoogleSignInHelper {
    
    /// Retrieves the Google sign-in credentials to authenticate with Firebase.
    /// - Throws: An error if the sign-in process fails or if the credentials are invalid.
    /// - Returns: A `GoogleSignInResult` containing the credentials and user information.
    /// - Note: This method facilitates the sign-in process by presenting the Google sign-in UI to the user and retrieves the required credentials for Firebase authentication.
    func getCredential() async throws -> GoogleSignInResult {
        // Ensure the root view controller is available for presenting the sign-in UI.
        guard let rootViewController = try getRootViewController() else {
            throw AppError.systemError
        }
        
        // Perform Google sign-in and retrieve the result.
        let signInResult = try await signIn(with: rootViewController)
        
        // Extract the ID token from the sign-in result, and if missing, throw an error.
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw AppError.userAccountError("We couldn't complete the sign-in process. Please try again.")
        }
        
        // Return the Google sign-in result with the credentials and user information.
        return GoogleSignInResult(
            credential: GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            ),
            name: signInResult.user.profile?.name,
            email: signInResult.user.profile?.email
        )
    }
    
    /// Retrives the current authenticated user's ID.
    /// - Throws: An error if the user is not authenticated.
    /// - Returns: The authenticated user's ID.
    func getUser() async throws -> String {
        // Ensure the user is authenticated with Firebase.
        guard let user = Auth.auth().currentUser else {
            throw AppError.userNotAuthenticated
        }
        return user.uid
    }
    
    // MARK: - Helper Methods
    
    /// Retrieves the root view controller of the application.
    /// - Throws: An error if the root view controller cannot be found.
    /// - Returns: The root view controller of the application.
    private func getRootViewController() throws -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AppError.systemError
        }
        return rootViewController
    }
    
    /// Performs the Google sign-in process.
    /// - Parameter rootViewController: The view controller to present the sign-in UI.
    /// - Throws: An error if the sign-in process fails.
    /// - Returns: The result of the sign-in process.
    private func signIn(with rootViewController: UIViewController) async throws -> GIDSignInResult {
        do {
            return try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        } catch {
            throw AppError.networkError
        }
    }
}

