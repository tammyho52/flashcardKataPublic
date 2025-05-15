//
//  ScoreSummaryBox.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Component that displays the summary of scores for a review session,
//  showing the count of correct and incorrect answers.

import SwiftUI

/// A view that displays the summary of scores for a review session,
struct ScoreSummaryBox: View {
    // MARK: - Properties
    let correctScore: Int
    let incorrectScore: Int

    // MARK: - Body
    var body: some View {
        VStack(spacing: 10) {
            IndividualScore(scoreType: .correct, score: correctScore)
            Divider()
                .frame(height: 2.5)
                .background(.white)
            IndividualScore(scoreType: .incorrect, score: incorrectScore)
        }
        .padding(.leading, 10)
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .background(Color.customSecondary)
        .clipDefaultShape()
    }
}

// MARK: - Private Views
private struct IndividualScore: View {
    let scoreType: ScoreType
    let score: Int

    var body: some View {
        HStack {
            IconView(scoreType: scoreType, font: .title3)
                .padding(.trailing, 10)
            HStack {
                Text("\(score)")
                    .fontWeight(.semibold)
                    .font(.customTitle)
                    .accessibilityIdentifier(scoreType == .correct ? "correctScoreReviewSessionSummary" : "incorrectScoreReviewSessionSummary")
                Text("\(scoreType.rawValue.capitalized)")
                    .fontWeight(.semibold)
                    .font(.customTitle3)
            }
            .padding(.leading, 10)
        }
        .foregroundStyle(.white)
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ScoreSummaryBox(correctScore: 5, incorrectScore: 5)
}
#endif
