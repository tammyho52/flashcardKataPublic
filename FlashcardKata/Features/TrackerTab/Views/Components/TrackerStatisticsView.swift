//
//  TrackerStatisticsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays three key statistics aggregating review session summaries for a selected date.

import SwiftUI

struct TrackerStatisticsView: View {
    let flashcardCount: Int
    let streakCount: Int
    let timeStudied: String

    var body: some View {
        HStack(spacing: 7.5) {
            StatisticBoxView(trackerStatistic: .flashcard(flashcardCount))
            StatisticBoxView(trackerStatistic: .streak(streakCount))
            StatisticBoxView(trackerStatistic: .time(timeStudied))
        }
    }
}

#if DEBUG
#Preview {
    TrackerStatisticsView(flashcardCount: 10, streakCount: 5, timeStudied: "1:30")
}
#endif
