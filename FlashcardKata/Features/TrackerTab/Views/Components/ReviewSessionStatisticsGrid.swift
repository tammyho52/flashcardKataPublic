//
//  ReviewSessionStatistics.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays reviewed flashcards statistics by deck.

import SwiftUI

struct ReviewSessionStatisticsGrid: View {

    @Binding var chartItems: [ChartItem]
    let columns = [GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 7.5) {
            ForEach(chartItems) { chartItem in
                ChartItemDisplay(chartItem: chartItem)
            }
        }
        .padding(.bottom, 30)
    }
}

#if DEBUG
#Preview {
    ReviewSessionStatisticsGrid(chartItems: .constant(ChartItem.sampleArray))

}
#endif
