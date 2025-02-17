//
//  View+Extensions.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

extension View {
    func defaultCornerRadius(_ radius: CGFloat = DesignConstants.Layout.cornerRadius) -> some View {
        self.cornerRadius(radius)
    }
    
    func clipDefaultShape() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))
    }
    
    func applyClearNavigationBarStyle() -> some View {
        self.modifier(ClearGlobalNavigationBarStyle())
    }
    
    func applyColoredNavigationBarStyle(backgroundGradientColors: (navigationBarBackground: Color, backgroundGradientPrimaryColor: Color, backgroundGradientSecondaryColor: Color), disableBackgroundColor: Bool = false) -> some View {
        self.modifier(ColoredGlobalNavigationBarStyle(backgroundGradientColors: backgroundGradientColors, disableBackgroundColor: disableBackgroundColor))
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

