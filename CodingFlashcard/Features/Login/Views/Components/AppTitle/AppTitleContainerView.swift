//
//  AppTitleView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
            cachedLetterWidth = letterWidth
        }
        .observeGeometry(onChange: { size, _ in
            screenWidth = size.width
        })
    }
    
    private func adjustLetterWidthForLongestWord() -> CGFloat {
        let longestWordLength = appTitle.map { $0.count }.max() ?? 0
        let sidePadding: CGFloat = 30
        let letterPadding: CGFloat = letterSpacing * CGFloat(longestWordLength)
        let totalPadding = sidePadding + letterPadding
        
        return (screenWidth - totalPadding) / CGFloat(longestWordLength)
    }
    
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
