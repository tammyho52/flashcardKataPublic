//
//  IconView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a large icon representing whether a user got a correct or incorrect score.

import SwiftUI

struct IconView: View {
    let scoreType: ScoreType
    var font: Font = .title

    var body: some View {
        Image(systemName: scoreType.symbol)
            .font(font)
            .foregroundStyle(.white)
            .padding()
            .background(scoreType.backgroundColor)
            .clipDefaultShape()
            .shadow(radius: 2.5)
    }
}

#if DEBUG
#Preview {
    IconView(scoreType: .correct)
}
#endif
