//
//  LoginButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct PrimaryButton: View {
    var isDisabled: Bool
    let text: String
    let action: () async -> Void
    
    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }) {
            Text(text)
        }
        .buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
    }
}

#if DEBUG
#Preview {
    PrimaryButton(isDisabled: false, text: "Create Account", action: {})
}
#endif
