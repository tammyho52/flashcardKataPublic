//
//  InputControlStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Provides a reusable view modifier for styling text fields.

import SwiftUI

/// A view modifier that applies a consistent style to text fields,
struct TextFieldStyle: ViewModifier {
    // MARK: - Properties
    let backgroundColor: Color
    
    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .padding(7.5)
            .background(backgroundColor.opacity(0.2))
            .background(.white)
            .clipDefaultShape()
    }
}

extension View {
    /// A convenience method to apply the text field style with a specified background color.
    func applyTextFieldStyle(backgroundColor: Color) -> some View {
        self.modifier(TextFieldStyle(backgroundColor: backgroundColor))
    }
}
