//
//  SignInWithApple.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This struct defines a SwiftUI wrapper for the Sign In with Apple button, enabling seamless integration
//  of the ASAuthorizationAppleIDButton into SwiftUI views.

import SwiftUI
import AuthenticationServices

/// SwiftUI representable view for the Sign In with Apple button.
struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {

    }
}
