//
//  ReauthenticationScreen.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReauthenticationScreen: View {
    @Environment(\.dismiss) var dismiss
    @State var email: String = ""
    @State var password: String = ""
    @Binding var showReauthenticationView: Bool
    
    let buttonAction: (_ email: String, _ password: String) async -> Void
    let buttonTitle = "Delete Account"
    var isDisabled: Bool {
        email.isEmpty || password.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AuthenticationTextField(
                        text: $email,
                        symbol: SignInSignUpField.email.symbol,
                        textFieldLabel: SignInSignUpField.email.description
                    )
                    .textContentType(.none)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    
                    AuthenticationTextField(
                        text: $password,
                        symbol: SignInSignUpField.password.symbol,
                        textFieldLabel: SignInSignUpField.password.description,
                        isTextFieldSecure: true
                    )
                    .textContentType(.none)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    
                    Text("Deleted account information cannot be recovered.")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                    
                    PrimaryButton(
                        isDisabled: isDisabled,
                        text: buttonTitle,
                        action: { await buttonAction(email, password) }
                    )
                    .padding(.top)
                }
            }
            .padding([.horizontal, .top])
            .navigationTitle("Reauthentication")
            .toolbar {
                toolbarBackButton { dismiss() }
            }
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var showReauthenticationView: Bool = true
    
    NavigationStack {
        
    }
    .sheet(isPresented: $showReauthenticationView) {
        ReauthenticationScreen(showReauthenticationView: .constant(true), buttonAction: {email,password in })
    }
}
#endif
