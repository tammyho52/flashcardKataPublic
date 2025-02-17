//
//  SignUpTextField.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct AuthenticationTextField: View {
    @Binding var text: String
    let symbol: String
    let textFieldLabel: String
    var isTextFieldSecure: Bool = false
    
    var body: some View {
        HStack {
            InlineIcon(symbol: symbol)
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
}

#if DEBUG
#Preview {
    AuthenticationTextField(text: .constant(""), symbol: "person.fill", textFieldLabel: "Full Name")
}
#endif
