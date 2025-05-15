//
//  IconView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A large icon representing the user's score, used in confetti views.

import SwiftUI

/// A view that displays an icon representing a score type.
struct IconView: View {
    // MARK: - Properties
    let scoreType: ScoreType
    var font: Font = .title

    // MARK: - Body
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

// MARK: - Preview
#if DEBUG
#Preview {
    IconView(scoreType: .correct)
}
#endif
