//
//  StatisticBoxView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view is responsible for displaying individual review session summary metrics for a selected date.

import SwiftUI

struct StatisticBoxView: View {
    // MARK: - Properties
    @ScaledMetric var shapeHeight = 140

    let trackerStatistic: TrackerStatistic
    
    // MARK: - Body
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
            symbolIcon
        }
    }
    
    // MARK: - Private Views
    /// Displays the icon representing the statistic.
    private var symbolIcon: some View {
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

// MARK: - Preview
#if DEBUG
#Preview {
    HStack(spacing: 5) {
        // Example flashcard statistics
        StatisticBoxView(trackerStatistic: .flashcard(10))
        // Example streak statistics
        StatisticBoxView(trackerStatistic: .streak(5))
        // Example time statistics
        StatisticBoxView(trackerStatistic: .time("5:00"))
    }
}
#endif
