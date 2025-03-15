//
//  SignUpTextField.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom text field for authentication forms.

import SwiftUI

struct AuthenticationTextField: View {
    @Binding var text: String
    let symbol: String
    let textFieldLabel: String
    var isTextFieldSecure: Bool = false

    var body: some View {
        HStack {
            inlineIcon
                .padding(.trailing, 5)
            Group {
                if isTextFieldSecure {
                    SecureField(textFieldLabel, text: $text)
                } else {
                    TextField(textFieldLabel, text: $text)

                }
            }
            .primaryTextfieldStyle()
        }
    }

    var inlineIcon: some View {
        Image(systemName: symbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundStyle(Color.customPrimary)
            .font(.customTitle3)
    }
}

#if DEBUG
#Preview {
    AuthenticationTextField(text: .constant(""), symbol: "person.fill", textFieldLabel: "Full Name")
}
#endif
