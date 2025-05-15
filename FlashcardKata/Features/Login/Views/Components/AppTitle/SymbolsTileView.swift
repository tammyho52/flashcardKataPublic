//
//  SymbolTileView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A horizontal row of decorative SF Symbol tiles displayed below the app title.
//  Each symbol may optionally appear flipped to provide visual variety.

import SwiftUI

/// A view that renders a horizontal row of icon tiles using SF Symbol.
/// Typically used beneath the app title for a decorative effect.
struct SymbolsTileView: View {
    // MARK: - Constants
    /// The SFSymbol figures with their respective flipped states.
    private let figuresWithFlip: [(symbol: String, isFlipped: Bool)] = [
        ("figure.outdoor.cycle", false),
        ("figure.cross.training", false),
        ("figure.mixed.cardio", false),
        ("figure.run", true),
        ("figure.yoga", true)
    ]
    private let iconSpacing: CGFloat = 15
    private let sideLengthDivisor: CGFloat = 9

    // MARK: - Computed Properties
    /// The side length of the icon tiles, dynamically scaled based on the screen width.
    private var sideLength: CGFloat {
        return DesignConstants.screenWidth / sideLengthDivisor
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: iconSpacing) {
            ForEach(figuresWithFlip, id: \.0) { symbol, isFlipped in
                IconTileView(
                    symbol: symbol,
                    isFlipped: isFlipped,
                    sideLength: sideLength
                )
            }
        }
    }
}

// MARK: - IconTileView
/// A view that displays an icon tile with a specific symbol and horizontal rotation (flip) for visual variation.
private struct IconTileView: View {
    let symbol: String
    let isFlipped: Bool
    var sideLength: CGFloat

    private let iconPadding: CGFloat = 10

    var body: some View {
        Image(systemName: symbol)
            .font(.title3)
            .padding(iconPadding)
            .applyIconTileStyle(width: sideLength, height: sideLength)
            .ifCondition(isFlipped) { view in
                // Applies a 180-degree rotation to the icon tile if flipped (for visual symmetry).
                view.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        SymbolsTileView()
    }
}
#endif
