//
//  TrackerStatisticsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view displays three key statistics that summarizes a user's review progress.

import SwiftUI

/// A view that displays three key statistics: flashcard count, streak count, and time studied.
struct TrackerStatisticsView: View {
    // MARK: - Properties
    let flashcardCount: Int
    let streakCount: Int
    let timeStudied: String

    // MARK: - Body
    var body: some View {
        HStack(spacing: 7.5) {
            StatisticBoxView(trackerStatistic: .flashcard(flashcardCount))
            StatisticBoxView(trackerStatistic: .streak(streakCount))
            StatisticBoxView(trackerStatistic: .time(timeStudied))
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    TrackerStatisticsView(flashcardCount: 10, streakCount: 5, timeStudied: "1:30")
}
#endif
