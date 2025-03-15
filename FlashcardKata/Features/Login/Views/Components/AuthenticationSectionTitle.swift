//
//  AuthenticationSectionTitle.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Custom section title for authentication forms.

import SwiftUI

struct AuthenticationSectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.customTitle)
            .fontWeight(.semibold)
            .foregroundStyle(Color.customPrimary)
    }
}

#if DEBUG
#Preview {
    AuthenticationSectionTitle(text: "Sign Up")
}
#endif
