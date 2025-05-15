//
//  GoogleAuthenticationService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Service class to hangle Google authentication with Firebase.

import Foundation
import FirebaseAuth

@MainActor
final class GoogleAuthenticationService {
    let googleSignInHelper: GoogleSignInHelper = GoogleSignInHelper()
    
    /// Signs in the user with Google using Firebase authentication.
    /// - Parameter authenticationManager: The authentication manager to handle authentication state.
    /// - Throws: Any errors that occur during the sign-in or user profile creation process.
    /// - Note: If the user is new, a user profile will be created in Firebase.
    func signIn(authenticationManager: FirebaseAuthenticationManager) async throws {
        // Obtain a Google sign-in credential using GoogleSignInHelper.
        let result = try await googleSignInHelper.getCredential()
        let credential = result.credential
        
        // Sign in with the obtained credential using Firebase authentication.
        let authDataResult = try await authenticationManager.signIn(with: credential)
        
        // Set the authentication provider to Google
        await authenticationManager.setAuthenticationProvider(.google)

        // Check if the user is new, and create a user profile if so
        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? false
        if isNewUser {
            try await authenticationManager.createUserProfile(user: authDataResult.user)
        }
    }
    
    /// Reauthenticates the current user with their Google credentials.
    /// - Throws: An error if the user is not authenticated or if the reauthentication fails.
    func reauthenticate() async throws {
        // Ensure the user is authenticated before attempting reauthentication
        guard let user = Auth.auth().currentUser else { throw AppError.userAccountError("User is not authenticated.") }
        
        // Obtain new Google credentials and reauthenticate the user
        let result = try await googleSignInHelper.getCredential()
        try await user.reauthenticate(with: result.credential)
    }
}
