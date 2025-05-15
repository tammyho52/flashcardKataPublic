//
//  LargeTileStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Modifier to apply icon tile style for app title icons.

import SwiftUI

/// A view modifier that applies a specific style to an icon tile.
struct IconTileStyle: ViewModifier {
    // MARK: - Properties
    var width: CGFloat
    var height: CGFloat

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color.customSecondary, Color.customAccent, Color.customAccent2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipDefaultShape()
            .overlay(
                RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                    .stroke(.white, lineWidth: 2.5)
            )
            .applyCoverShadow()
    }
}

extension View {
    /// A convenience method to apply the icon tile style.
    /// - Parameters:
    ///   - width: The width of the tile.
    ///   - height: The height of the tile.
    /// - Returns: A view with the icon tile style applied.
    func applyIconTileStyle(width: CGFloat, height: CGFloat) -> some View {
        self.modifier(IconTileStyle(width: width, height: height))
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    Image(systemName: "person")
        .padding()
        .background(Color.customSecondary)
        .clipDefaultShape()
        .applyIconTileStyle(width: 50, height: 50)
}
#endif
