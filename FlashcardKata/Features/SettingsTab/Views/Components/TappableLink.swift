//
//  TappableLink.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view formats text into a tappable link with specific styling, providing a
//  reusable component for navigation or triggering actions.

import SwiftUI

/// A view that formats text into a tappable link with custom styling.
struct TappableLink: View {
    // MARK: - Properties
    let text: String
    let action: () -> Void

    // MARK: - Body
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .foregroundStyle(Colors.primaryText)
            .underline(color: Colors.textBackground)
            .onTapGesture(perform: action)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    TappableLink(text: "Link", action: {})
}
#endif
