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

struct GoogleSignInResultModel {
    let credential: AuthCredential
    let name: String?
    let email: String?
}

final class GoogleSignInHelper {

    // Generates the tokens for Google User Sign-In.
    @MainActor
    func getCredential() async throws -> GoogleSignInResultModel {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw URLError(.cannotFindHost)
        }

        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }

        return GoogleSignInResultModel(
            credential: GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            ),
            name: signInResult.user.profile?.name,
            email: signInResult.user.profile?.email
        )
    }

    func getUser() async throws -> String {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        return user.uid
    }
}
