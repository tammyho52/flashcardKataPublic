//
//  SignUpTextField.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A custom text field for authentication forms, featuring an
//  inline icon and supporting both secure and regular text input.

import SwiftUI

/// A custom text field for authentication forms, allowing for both secure and regular text input.
struct AuthenticationTextField: View {
    // MARK: - Properties
    @Binding var text: String // The text input by the user
    let symbol: String // Inline icon symbol name
    let textFieldLabel: String // Label displayed inside the text field
    var isTextFieldSecure: Bool = false // Flag to determine if the text field should be secure (password entry)

    // MARK: - Body
    var body: some View {
        HStack {
            inlineIcon
                .padding(.trailing, 5)
            
            Group {
                // Use SecureField if isTextFieldSecure is true, otherwise use TextField
                if isTextFieldSecure {
                    SecureField(textFieldLabel, text: $text)
                } else {
                    TextField(textFieldLabel, text: $text)

                }
            }
            .primaryTextfieldStyle() // Custom text field style
        }
    }
    
    // MARK: - Inline Icon
    /// The inline icon displayed next to the text field using the provided `symbol`.
    var inlineIcon: some View {
        Image(systemName: symbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundStyle(Color.customPrimary)
            .font(.customTitle3)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    AuthenticationTextField(
        text: .constant(""),
        symbol: "person.fill",
        textFieldLabel: "Full Name"
    )
}
#endif
