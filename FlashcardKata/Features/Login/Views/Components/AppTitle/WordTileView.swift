//
//  TitleTileView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A view that displays a row of letter tiles to represent a word for the app title.

import SwiftUI

/// A view that arranges a set of letter tiles horizontally to form a row,
/// with each letter of the app's title represented by a tile.
struct WordTileView: View {
    // MARK: - Properties
    let letters: [String]
    let letterSpacing: CGFloat
    var width: CGFloat
    var height: CGFloat

    // MARK: - Body
    var body: some View {
        HStack(spacing: letterSpacing) {
            ForEach(letters.indices, id: \.self) { index in
                CharacterTileView(
                    character: letters[index],
                    width: width,
                    height: height
                )
            }
        }
    }
}

// MARK: - CharacterTileView
/// A view that displays a single letter inside a tile with shadow effect.
private struct CharacterTileView: View {
    var character: String
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Text(character)
            .fontWeight(.bold)
            .applyIconTileStyle(width: width, height: height) // Apply custom tile style (e.g. background, border)
            .applyCoverShadow()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.blue
            .ignoresSafeArea()
        WordTileView(
            letters: ["F", "L", "A", "S", "H", "C", "A", "R", "D"],
            letterSpacing: 10,
            width: 35,
            height: 40
        )
    }
}
#endif
