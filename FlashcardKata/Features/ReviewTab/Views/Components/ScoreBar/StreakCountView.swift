//
//  StreakCountView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays streak information, used for Streak review mode sessions.

import SwiftUI

/// A view that displays the current streak count and the high streak count.
struct StreakCountView: View {
    // MARK: - Properties
    @Binding var incorrectScore: Int
    @Binding var correctScore: Int

    let currentStreak: Int
    let highStreak: Int

    // MARK: - Body
    var body: some View {
        VStack {
            Text("Current: \(currentStreak)")
            Text("Streak: \(highStreak)")
        }
        .frame(maxWidth: .infinity)
        .font(.title3)
        .foregroundStyle(.white)
        .fontWeight(.semibold)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ZStack {
        Color.gray
        StreakCountView(incorrectScore: .constant(0), correctScore: .constant(0), currentStreak: 0, highStreak: 0)
    }
}
#endif
