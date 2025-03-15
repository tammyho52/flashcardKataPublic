//
//  DeckCoverBackgroundGradient.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Background gradient view for deck covers, adjusting saturation for subdecks.

import SwiftUI

struct DeckCoverBackgroundGradient: View {
    let primaryColor: Color
    let secondaryColor: Color
    let isSubdeck: Bool

    var body: some View {
        LinearGradient(colors: [primaryColor, secondaryColor], startPoint: .topLeading, endPoint: .bottomTrailing)
            .saturation(isSubdeck ? 0.5 : 1) // Reduce saturation for subdecks.
    }
}

extension View {
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

#if DEBUG
#Preview {
    DeckCoverBackgroundGradient(primaryColor: .darkBlue, secondaryColor: .lightBlue, isSubdeck: true)
}
#endif
