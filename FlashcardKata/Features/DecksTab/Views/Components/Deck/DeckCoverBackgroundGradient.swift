//
//  DeckCoverBackgroundGradient.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that provides a customizable background gradient for deck covers,
//  adjusting its saturation based on whether the deck is a subdeck.

import SwiftUI

/// A view that renders a linear gradient background for deck covers.
struct DeckCoverBackgroundGradient: View {
    // MARK: - Properties
    let primaryColor: Color
    let secondaryColor: Color
    let isSubdeck: Bool
    
    // MARK: - Body
    var body: some View {
        LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
            .saturation(isSubdeck ? 0.5 : 1) // Adjusts saturation for subdecks.
    }
}

extension View {
    /// A convenience method to apply a deck cover background gradient.
    func applyDeckCoverBackgroundGradient(primaryColor: Color, secondaryColor: Color, isSubdeck: Bool) -> some View {
        self.background(
            DeckCoverBackgroundGradient(
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                isSubdeck: isSubdeck
            )
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    DeckCoverBackgroundGradient(primaryColor: .darkBlue, secondaryColor: .lightBlue, isSubdeck: true)
}
#endif
