//
//  WebViewAlertModifier.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct WebViewAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    let title: String
    let message: String
    let dismissAction: () -> Void
    
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
    func webViewAlert(isPresented: Binding<Bool>, title: String, message: String, dismissAction: @escaping () -> Void) -> some View {
        self
            .modifier(WebViewAlertModifier(isPresented: isPresented, title: title, message: message, dismissAction: dismissAction))
    }
}

#if DEBUG
#Preview {
    VStack {
        Text("Test")
    }
    .modifier(WebViewAlertModifier(isPresented: .constant(true), title: "Terms and Conditions", message: "Please try again later, or contact support for immediate assistance.", dismissAction: {}))
}
#endif
