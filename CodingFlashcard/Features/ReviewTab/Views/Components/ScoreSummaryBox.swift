//
//  ScoreBox.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ScoreSummaryBox: View {
    let correctScore: Int
    let incorrectScore: Int
    
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

#if DEBUG
#Preview {
    ScoreSummaryBox(correctScore: 5, incorrectScore: 5)
}
#endif
