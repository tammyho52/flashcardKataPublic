//
//  WebViewAlertModifier.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view modifier provides a reusable mechanism for displaying alerts related to web view errors.

import SwiftUI

/// A view modifier that presents an alert when a web view error occurs.
struct WebViewAlertModifier: ViewModifier {
    // MARK: - Properties
    @Binding var isPresented: Bool

    let title: String
    let message: String
    let dismissAction: () -> Void

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button("Ok") {
                    dismissAction()
                    isPresented = false
                }
            } message: {
                Text(message)
            }
    }

}

extension View {
    /// A convenience method to present a web view alert.
    func webViewAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        dismissAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            WebViewAlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                dismissAction: dismissAction
            )
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    VStack {
        Text("Test")
    }
    .modifier(
        WebViewAlertModifier(
            isPresented: .constant(true),
            title: "Terms and Conditions",
            message: "Please try again later, or contact support for immediate assistance.",
            dismissAction: {}
        )
    )
}
#endif
