//
//  MetricCard.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Component that displays a metric card with a number, metric, and icon for the review session summary.

import SwiftUI

/// A view that displays a metric card to summarize review session statistics.
struct MetricCard: View {
    // MARK: - Properties
    let number: Int
    let metric: String
    let imageName: String
    let imageColor: Color
    let backgroundColor: Color

    // MARK: - Body
    var body: some View {
        VStack {
            Text("\(number)")
                .font(.customTitle3)
                .foregroundStyle(DesignConstants.Colors.primaryText)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .accessibilityIdentifier("\(metric)CompletedCount")
            Text(metric)
                .font(.customHeadline)
                .foregroundStyle(DesignConstants.Colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundStyle(imageColor)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.trailing, 5)
        }
        .padding()
        .background(backgroundColor)
        .clipDefaultShape()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    MetricCard(
        number: 30,
        metric: "Minutes",
        imageName: "timer",
        imageColor: Color.customSecondary,
        backgroundColor: .white.opacity(0.8)
    )
}
#endif
