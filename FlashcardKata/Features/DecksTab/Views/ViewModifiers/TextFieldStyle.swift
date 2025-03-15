//
//  InputControlStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View modifier for textfield style.

import SwiftUI

struct TextFieldStyle: ViewModifier {
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .padding(7.5)
            .background(backgroundColor.opacity(0.2))
            .background(.white)
            .clipDefaultShape()
    }
}

extension View {
    func applyTextFieldStyle(backgroundColor: Color) -> some View {
        self.modifier(TextFieldStyle(backgroundColor: backgroundColor))
    }
}
