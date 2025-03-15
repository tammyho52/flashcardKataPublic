//
//  TitleTileView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a row of letter tiles for app title.

import SwiftUI

struct WordTileView: View {

    let letters: [String]
    let letterSpacing: CGFloat
    var width: CGFloat
    var height: CGFloat

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

private struct CharacterTileView: View {
    var character: String
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Text(character)
            .fontWeight(.bold)
            .applyIconTileStyle(width: width, height: height)
            .applyCoverShadow()
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.blue
            .ignoresSafeArea()
        WordTileView(letters: ["F", "L", "A", "S", "H", "C", "A", "R", "D"], letterSpacing: 10, width: 35, height: 40)
    }
}
#endif
