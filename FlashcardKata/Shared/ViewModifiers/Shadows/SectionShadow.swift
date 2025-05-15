//
//  SectionShadow.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View modifer used for section shadows.

import SwiftUI

struct SectionShadow: ViewModifier {
    var color: Color = .gray

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.3), radius: 1, x: 0.5, y: 2)
            .shadow(color: color.opacity(0.5), radius: 0.5, x: 0, y: 1)
    }
}

extension View {
    func applySectionShadow(color: Color = .gray) -> some View {
        self.modifier(SectionShadow(color: color))
    }
}
