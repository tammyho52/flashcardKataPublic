//
//  ScoreBarView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Score bar component at the bottom of review session screen - display format is dependent on the Review Mode.

import SwiftUI
import Combine

struct ScoreBarView: View {
    @Binding var correctScore: Int
    @Binding var incorrectScore: Int
    @Binding var currentStreak: Int
    @Binding var highStreak: Int
    @Binding var targetCorrectCount: Int?
    @Binding var reviewMode: ReviewMode
    @Binding var secondsRemaining: Int

    var body: some View {
        HStack {
            GeneralScoreView(score: $incorrectScore, scoreType: .incorrect)
                .padding(.leading, 2.5)

            // Displays different center portion based on Review Mode.
            switch reviewMode {
            case .practice:
                practiceText
            case .target:
                if let targetCorrectCount {
                    targetText(targetCorrectCount: targetCorrectCount)
                } else {
                    Spacer()
                }
            case .timed:
                TimerView(secondsRemaining: $secondsRemaining)
            case .streak:
                StreakCountView(
                    incorrectScore: $incorrectScore,
                    correctScore: $correctScore,
                    currentStreak: currentStreak,
                    highStreak: highStreak
                )
            }

            GeneralScoreView(score: $correctScore, scoreType: .correct)
                .padding(.trailing, 2.5)
        }
        .frame(maxWidth: .infinity)
        .padding(5)
        .background(Capsule().foregroundStyle(Color.customAccent))
        .applyCoverShadow()
    }

    // MARK: - Text Views
    var practiceText: some View {
        HStack {
            Spacer()
            Text("Practice")
                .foregroundStyle(.white)
                .font(.customTitle2)
                .fontWeight(.bold)
            Spacer()
        }
    }

    func targetText(targetCorrectCount: Int) -> some View {
        Text("Target: \(targetCorrectCount)")
            .foregroundStyle(.white)
            .font(.customTitle2)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#if DEBUG
#Preview {
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        reviewMode: .constant(.practice),
        secondsRemaining: .constant(60)
    )
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        reviewMode: .constant(.target),
        secondsRemaining: .constant(60)
    )
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        reviewMode: .constant(.timed),
        secondsRemaining: .constant(60)
    )
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        reviewMode: .constant(.streak),
        secondsRemaining: .constant(60)
    )
}
#endif
