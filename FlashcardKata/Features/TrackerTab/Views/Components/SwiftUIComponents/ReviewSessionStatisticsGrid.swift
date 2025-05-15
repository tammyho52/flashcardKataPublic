//
//  ReviewSessionStatistics.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view displays a grid of reviewed flashcards statistics by deck.

import SwiftUI

/// A view that displays reviewed flashcards statistics by deck.
struct ReviewSessionStatisticsGrid: View {
    // MARK: - Properties
    @Binding var chartItems: [ChartItem]
    let columns = [GridItem(.flexible())]

    // MARK: - Body
    var body: some View {
        LazyVGrid(columns: columns, spacing: 7.5) {
            ForEach(chartItems) { chartItem in
                ChartItemDisplay(chartItem: chartItem)
            }
        }
        .padding(.bottom, 30)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ReviewSessionStatisticsGrid(chartItems: .constant(ChartItem.sampleArray))

}
#endif
