//
//  CalendarPieChart.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI
import Charts

struct DecksStudiedChart: View {
    @ScaledMetric var chartHeight = 200
    @Binding var chartItems: [ChartItem]
    
    var body: some View {
        ZStack(alignment: .center) {
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

#if DEBUG
#Preview {
    DecksStudiedChart(
        chartItems: .constant(ChartItem.sampleArray)
    )
    .padding()
}
#endif
