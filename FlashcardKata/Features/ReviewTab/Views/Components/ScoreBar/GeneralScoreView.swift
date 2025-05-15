//
//  GeneralScoreView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays the current score for either correct or incorrect scores.

import SwiftUI

/// A view that displays the score within the score bar.
struct GeneralScoreView: View {
    // MARK: - Properties
    @Binding var score: Int
    let scoreType: ScoreType

    // MARK: - Body
    var body: some View {
        HStack {
            Image(systemName: scoreType.symbol)
                .foregroundStyle(scoreType.backgroundColor)
                .font(.title2)
                .padding(.trailing, 5)
            Text("\(score)")
                .font(.customHeadline)
                .fontWeight(.bold)
        }
        .frame(width: 75)
        .fontWeight(.semibold)
        .padding()
        .background(.white.opacity(0.8))
        .background(.white)
        .clipShape(Capsule())
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    GeneralScoreView(score: .constant(1), scoreType: .correct)
}
#endif
