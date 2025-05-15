//
//  View+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A collection of view utility methods to apply custom view modifiers and reusable styles.

import SwiftUI

extension View {
    /// Sets the default corner radius for a view.
    func defaultCornerRadius(_ radius: CGFloat = DesignConstants.Layout.cornerRadius) -> some View {
        self.cornerRadius(radius)
    }

    /// Clips the view to a default shape (rounded rectangle with default corner radius).
    func clipDefaultShape() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))
    }

    func applyClearNavigationBarStyle() -> some View {
        self.modifier(ClearGlobalNavigationBarStyle())
    }

    func applyColoredNavigationBarStyle(
        backgroundGradientColors: BackgroundGradientColors,
        disableBackgroundColor: Bool = false
    ) -> some View {
        self.modifier(ColoredGlobalNavigationBarStyle(
            backgroundGradientColors: backgroundGradientColors,
            disableBackgroundColor: disableBackgroundColor
        ))
    }

    @ViewBuilder
    func applyInfiniteWidth(if shouldApply: Bool) -> some View {
        if shouldApply {
            self.frame(maxWidth: .infinity, alignment: .leading)
        } else {
            self
        }
    }

    @ViewBuilder
    func ifCondition<Content: View>(_ condition: Bool, apply: (Self) -> Content) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }

}
