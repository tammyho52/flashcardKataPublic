//
//  CoverShadow.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View modifier used for cover shadows.

import SwiftUI

struct CoverShadow: ViewModifier {
    var color: Color = .gray

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3), radius: 2, x: 1, y: 3)
            .shadow(color: color.opacity(0.5), radius: 1, x: 0, y: 2)
    }
}

extension View {
    func applyCoverShadow(color: Color = .gray) -> some View {
        self.modifier(CoverShadow(color: color))
    }
}
