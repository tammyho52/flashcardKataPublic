//
//  GoogleAuthenticationService.swift
//  FlashcardKata
//
//  Created by Tammy Ho on 3/3/25.
//
//  Service class to hangle Google authentication with Firebase.

import Foundation
import FirebaseAuth

final class GoogleAuthenticationService {
    let googleSignInHelper: GoogleSignInHelper = GoogleSignInHelper()

    func signIn(authenticationManager: AuthenticationManager) async {
        do {
            let result = try await googleSignInHelper.getCredential()
            let credential = result.credential
            let authDataResult = try await Auth.auth().signIn(with: credential)
            await authenticationManager.setAuthenticationProvider(.google)

            let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? false
            if isNewUser {
                try await authenticationManager.createUserProfile(user: authDataResult.user)
            }
        } catch {
            await setAuthenticationErrorToast(authenticationManager: authenticationManager)
        }
    }

    @MainActor
    private func setAuthenticationErrorToast(authenticationManager: AuthenticationManager) {
        authenticationManager.authenticationToast = Toast(style: .error, message: "Unable to complete authentication.")
    }

    func reauthenticate() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthenticationError.userNotAuthenticated }
        let result = try await googleSignInHelper.getCredential()
        try await user.reauthenticate(with: result.credential)
    }
}
