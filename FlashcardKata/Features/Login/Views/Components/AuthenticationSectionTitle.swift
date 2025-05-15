//
//  AuthenticationSectionTitle.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Custom section title for authentication forms.

import SwiftUI

/// A view that displays a customizable section title for authentication forms.
struct AuthenticationSectionTitle: View {
    // MARK: - Properties
    let text: String

    // MARK: - Body
    var body: some View {
        Text(text)
            .font(.customTitle)
            .fontWeight(.semibold)
            .foregroundStyle(Color.customPrimary)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    AuthenticationSectionTitle(text: "Sign Up")
}
#endif
