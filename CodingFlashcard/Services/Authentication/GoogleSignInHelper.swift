//
//  GoogleSignInHelper.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
    
    /// Generates the tokens for Google User Sign-In and information for the User Profile and returns the result as a 'GoogleSignInResultModel'.
    /// - Throws: 'URLError' if the sign-in process fails (i.e. if the top view controller cannot be found or the idToken is missing).
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
            credential: GoogleAuthProvider.credential(withIDToken: idToken, accessToken: signInResult.user.accessToken.tokenString),
            name: signInResult.user.profile?.name,
            email: signInResult.user.profile?.email
        )
    }
    
    func getUser() async throws -> String {
        guard let user = Auth.auth().currentUser else { throw URLError(.badServerResponse) }
        return user.uid
    }
}
