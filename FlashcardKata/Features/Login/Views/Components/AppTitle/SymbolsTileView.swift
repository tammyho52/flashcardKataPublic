//
//  SymbolTileView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a row of symbol tiles for app title.

import SwiftUI

struct SymbolsTileView: View {

    private let figures: [(symbol: String, isFlipped: Bool)] = [
        ("figure.outdoor.cycle", false),
        ("figure.cross.training", false),
        ("figure.mixed.cardio", false),
        ("figure.run", true),
        ("figure.yoga", true)
    ]
    private let iconSpacing: CGFloat = 15
    private let sideLengthDivisor: CGFloat = 9

    private var sideLength: CGFloat {
        return DesignConstants.screenWidth / sideLengthDivisor
    }

    var body: some View {
        HStack(spacing: iconSpacing) {
            ForEach(figures, id: \.0) { symbol, isFlipped in
                IconTileView(
                    symbol: symbol,
                    isFlipped: isFlipped,
                    sideLength: sideLength
                )
            }
        }
    }
}

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
                // Accounts for right-sided tiles to be flipped.
                view.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.gray
            .ignoresSafeArea()
        SymbolsTileView()
    }
}
#endif
