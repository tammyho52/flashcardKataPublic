//
//  BackgroundGradient.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View modifier that sets a background gradient using color palette.

import SwiftUI

struct BackgroundGradientModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            backgroundGradient.opacity(0.25)
            content
        }
    }
}

private var backgroundGradient: LinearGradient {
    LinearGradient(
        gradient: Gradient(
            colors: [
                Color.white, Color.customBackground, Color.customAccent3,
                Color.customAccent2, Color.customAccent
            ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension View {
    func applyBackgroundGradient() -> some View {
        self.modifier(BackgroundGradientModifier())
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    Text("Hello World")
        .applyBackgroundGradient()
}
#endif
