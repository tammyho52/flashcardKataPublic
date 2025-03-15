//
//  AppTitleView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays app title with letters and symbols.

import SwiftUI

struct AppTitleContainerView: View {
    @State private var screenWidth: CGFloat = DesignConstants.screenWidth
    @State private var cachedLetterWidth: CGFloat?
    @Binding var isTitleCentered: Bool
    let appTitle: [[String]] = ContentConstants.ContentStrings.appName
    let letterSpacing: CGFloat = 7.5
    let backgroundColor: Color = .white.opacity(0.8)

    var letterWidth: CGFloat {
        if let cachedLetterWidth {
            return cachedLetterWidth
        } else {
            let letterWidth = adjustLetterWidthForLongestWord()
            return letterWidth
        }
    }
    var letterHeight: CGFloat {
        return letterWidth * 1.2
    }

    var body: some View {
        VStack(spacing: 20) {
            appTitleView()
            SymbolsTileView()
        }
        .padding(20)
        .background(isTitleCentered ? backgroundColor : .clear)
        .clipDefaultShape()
        .onChange(of: letterWidth) {
            cachedLetterWidth = letterWidth // Prevents unnecessary tile width recalculation.
        }
        .observeGeometry(onChange: { size, _ in
            screenWidth = size.width // Records screen width for tile calculation.
        })
    }

    // Calculates padding to ensure title fits screen size.
    private func adjustLetterWidthForLongestWord() -> CGFloat {
        let longestWordLength = appTitle.map { $0.count }.max() ?? 0
        let sidePadding: CGFloat = 30
        let letterPadding: CGFloat = letterSpacing * CGFloat(longestWordLength)
        let totalPadding = sidePadding + letterPadding

        return (screenWidth - totalPadding) / CGFloat(longestWordLength)
    }

    // Sets each letter / symbol into a tile.
    private func appTitleView() -> some View {
        ForEach(appTitle.indices, id: \.self) { index in
            WordTileView(
                letters: appTitle[index],
                letterSpacing: letterSpacing,
                width: letterWidth,
                height: letterHeight
            )
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        Color.gray.edgesIgnoringSafeArea(.all)
        AppTitleContainerView(isTitleCentered: .constant(true))
    }
}
#endif
