//
//  PrimaryButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View representing a primary button.

import SwiftUI

struct PrimaryButton: View {
    var isDisabled: Bool
    let text: String
    let action: () async -> Void

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            Text(text)
        }
        .buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    PrimaryButton(isDisabled: false, text: "Create Account", action: {})
}
#endif
