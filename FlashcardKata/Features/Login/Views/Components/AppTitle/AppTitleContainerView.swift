//
//  AppTitleContainerView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A responsive container view that displays the app title using
//  a grid of letter tiles with decorative symbols underneath.

import SwiftUI

/// A view that renders the app's title using a grid of letter tiles, followed by a symbol display. Tiles sizes adapt to the screen width for consistent layout across devices.
struct AppTitleContainerView: View {
    // MARK: - Properties
    /// The width of the screen, used to calculate tile dimensions.
    @State private var screenWidth: CGFloat = DesignConstants.screenWidth
    /// Caches the calculated letter width to prevent unnecessary recalculations.
    @State private var cachedLetterWidth: CGFloat?
    /// A binding to determine if the title should be centered.
    @Binding var isTitleCentered: Bool
    
    // MARK: - Constants
    /// A 2D array of strings representing the app title by letter and word.
    let appTitle: [[String]] = ContentConstants.ContentStrings.appName
    /// Horizontal  spacing between letters in the title.
    let letterSpacing: CGFloat = 7.5
    let backgroundColor: Color = .white.opacity(0.8)

    // MARK: - Computed Properties
    
    /// Calculates the width of each letter tile, either from cache or calculated based on the longest word and available screen width.
    var letterWidth: CGFloat {
        if let cachedLetterWidth {
            return cachedLetterWidth
        } else {
            let letterWidth = adjustLetterWidthForLongestWord()
            return letterWidth
        }
    }
    
    /// Calculates the height of each letter tile based on the letter width.
    var letterHeight: CGFloat {
        return letterWidth * 1.2
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            appTitleView()
            SymbolsTileView()
        }
        .padding(20)
        .background(isTitleCentered ? backgroundColor : .clear)
        .clipDefaultShape()
        .onChange(of: letterWidth) {
            cachedLetterWidth = letterWidth // Caches the calculated letter width.
        }
        .observeGeometry(onChange: { size, _ in
            screenWidth = size.width // Records screen width for tile calculation.
        })
    }

    // MARK: - Private Methods
    // Calculates the letter width based on the longest word in the app title.
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

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.gray.edgesIgnoringSafeArea(.all)
        AppTitleContainerView(isTitleCentered: .constant(true))
    }
}
#endif
