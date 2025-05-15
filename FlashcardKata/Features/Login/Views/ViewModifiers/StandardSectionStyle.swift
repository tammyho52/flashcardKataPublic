//
//  StandardSectionStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A view modifier to apply consistence section style to authentication views, like sign in or sign up forms.

import SwiftUI

/// A view modifier that creates a standard section style for authentication views.
struct StandardSectionStyle: ViewModifier {
    // MARK: - Body
    /// Applies the standard section style to the content view.
    /// - Parameter content: The content to which the section style is applied.
    /// - Returns: A view with the standard section style applied.
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(.white)
            .clipDefaultShape()
            .applySectionShadow()
            .padding()
    }
}

extension View {
    /// A convenience method to apply the standard section style to any view.
    /// - Returns: A view with the standard section style applied.
    func standardSectionStyle() -> some View {
        self.modifier(StandardSectionStyle())
    }
}
