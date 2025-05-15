//
//  ScoreBarView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A reusable UI component that displays a dynamic score bar at the bottom of the review session screen.

import SwiftUI
import Combine

/// A view that displays the score bar with correct and incorrect scores, and review mode specific information.
struct ScoreBarView: View {
    // MARK: - Score Properties
    @Binding var correctScore: Int
    @Binding var incorrectScore: Int
    @Binding var reviewMode: ReviewMode
    
    // MARK: - Streak Review Mode Properties
    @Binding var currentStreak: Int
    @Binding var highStreak: Int
    
    // MARK: - Target Review Mode Properties
    @Binding var targetCorrectCount: Int?

    // MARK: - Timed Review Mode Properties
    @Binding var secondsRemaining: Int

    // MARK: - Body
    var body: some View {
        HStack {
            // Displays the incorrect score on the left side of the score bar.
            GeneralScoreView(score: $incorrectScore, scoreType: .incorrect)
                .padding(.leading, 2.5)
                .accessibilityIdentifier("incorrectScore")

            // Displays different center information for score bar based on review mode.
            switch reviewMode {
            case .practice:
                practiceText
                    .accessibilityIdentifier("practiceText")
            case .target:
                if let targetCorrectCount {
                    targetText(targetCorrectCount: targetCorrectCount)
                        .accessibilityIdentifier("targetText")
                } else {
                    Spacer()
                }
            case .timed:
                TimerView(secondsRemaining: $secondsRemaining)
                    .accessibilityIdentifier("timerText")
            case .streak:
                StreakCountView(
                    incorrectScore: $incorrectScore,
                    correctScore: $correctScore,
                    currentStreak: currentStreak,
                    highStreak: highStreak
                )
                .accessibilityIdentifier("streakCountText")
            }
            
            // Displays the correct score on the right side of the score bar.
            GeneralScoreView(score: $correctScore, scoreType: .correct)
                .padding(.trailing, 2.5)
                .accessibilityIdentifier("correctScore")
        }
        .frame(maxWidth: .infinity)
        .padding(5)
        .background(Capsule().foregroundStyle(Color.customAccent))
        .applyCoverShadow()
    }

    // MARK: - Text Views
    /// Display text for practice mode.
    private var practiceText: some View {
        HStack {
            Spacer()
            Text("Practice")
                .foregroundStyle(.white)
                .font(.customTitle2)
                .fontWeight(.bold)
            Spacer()
        }
    }
    
    /// Display text for target mode.
    private func targetText(targetCorrectCount: Int) -> some View {
        Text("Target: \(targetCorrectCount)")
            .foregroundStyle(.white)
            .font(.customTitle2)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    // Practice Review Mode
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        reviewMode: .constant(.practice),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        secondsRemaining: .constant(60)
    )
    
    // Target Review Mode
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        reviewMode: .constant(.target),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        secondsRemaining: .constant(60)
    )
    
    // Timed Review Mode
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        reviewMode: .constant(.timed),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        secondsRemaining: .constant(60)
    )
    
    // Streak Review Mode
    ScoreBarView(
        correctScore: .constant(5),
        incorrectScore: .constant(10),
        reviewMode: .constant(.streak),
        currentStreak: .constant(0),
        highStreak: .constant(0),
        targetCorrectCount: .constant(0),
        secondsRemaining: .constant(60)
    )
}
#endif
