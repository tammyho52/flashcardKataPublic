//
//  StatisticBoxView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct StatisticBoxView: View {
    @ScaledMetric var shapeHeight = 140

    let trackerStatistic: TrackerStatistic
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(trackerStatistic.value)
                .font(.customTitle)
                .foregroundStyle(DesignConstants.Colors.primaryText)
            Text(trackerStatistic.unit)
                .font(.customFootnote)
                .foregroundStyle(DesignConstants.Colors.secondaryText)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .fontWeight(.bold)
        .kerning(0.1)
        .frame(maxWidth: .infinity, minHeight: shapeHeight, alignment: .bottomLeading)
        .background(trackerStatistic.backgroundColor.opacity(0.7))
        .background(.white)
        .clipDefaultShape()
        .applyCoverShadow()
        .overlay(alignment: .topLeading) {
            Image(systemName: trackerStatistic.symbolName)
                .symbolVariant(.fill)
                .font(.title3)
                .padding(10)
                .foregroundStyle(.white)
                .background(trackerStatistic.iconBackgroundColor)
                .clipShape(Circle())
                .padding(10)
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 5) {
        StatisticBoxView(trackerStatistic: .flashcard(10))
        StatisticBoxView(trackerStatistic: .streak(5))
        StatisticBoxView(trackerStatistic: .time("5:00"))
    }
}
#endif
