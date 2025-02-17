//
//  PasswordUpdateScreen.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct PasswordUpdateScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var isSending: Bool = false
    @State private var email: String = ""
    @State var toast: Toast?
    
    let sendPasswordEmail: (String) async -> Void
    let buttonTitle = "Update Password"
    var isDisabled: Bool {
        email.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AuthenticationTextField(
                    text: $email,
                    symbol: SignInSignUpField.email.symbol,
                    textFieldLabel: SignInSignUpField.email.description
                )
                
                Button("Send Email") {
                    Task {
                        isSending = true
                        await sendPasswordEmail(email)
                        toast = Toast(style: .success, message: "Password Reset Email has been sent.")
                        isSending = false
                        email = ""
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
                .padding(.top)
                
                Spacer()
            }
            .padding([.horizontal, .top])
            .navigationTitle("Update Password")
            .addToast(toast: $toast)
            .applyOverlayProgressScreen(isViewDisabled: $isSending)
            .toolbar {
                toolbarBackButton { dismiss() }
            }
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var showSheet: Bool = true
    NavigationStack {
        
    }
    .sheet(isPresented: $showSheet) {
        PasswordUpdateScreen(sendPasswordEmail: { _ in })
    }
}
#endif
