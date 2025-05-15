//
//  DecksStudiedChart.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view displays a summary of decks reviewed in a pie chart format

import SwiftUI
import Charts

/// A view that displays a pie chart summarizing the flashcards reviewed across different decks.
struct DecksStudiedChart: View {
    // MARK: - Properties
    @ScaledMetric var chartHeight = 200
    @Binding var chartItems: [ChartItem]

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            // Pie chart displaying the number of flashcards reviewed for each deck
            Chart(chartItems) { chartItem in
                SectorMark(
                    angle: .value("Flashcards Reviewed", chartItem.flashcardCount),
                    innerRadius: .ratio(0.65),
                    angularInset: 5
                )
                .foregroundStyle(by: .value("Deck", chartItem.deck.name))
            }
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: chartHeight)
            .applyCoverShadow()
            .chartLegend(.hidden)
            .chartForegroundStyleScale(
                domain: chartItems.map { $0.deck.name },
                range: chartItems.map { $0.deck.theme.primaryColor }
            )

            // Displays the number of decks reviewed at the center of the chart
            VStack {
                Text("\(chartItems.count) Decks")
                    .font(.customTitle2)
                    .fontWeight(.bold)
                Text("Reviewed")
                    .font(.customHeadline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignConstants.Colors.secondaryText)
            }
            .padding(10)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    DecksStudiedChart(
        chartItems: .constant(ChartItem.sampleArray)
    )
    .padding()
}
#endif
