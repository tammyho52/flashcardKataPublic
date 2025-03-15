//
//  ChartItemDisplay.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Component displaying flashcard review metrics for a specified deck.

import SwiftUI

struct ChartItemDisplay: View {
    @Environment(\.sizeCategory) var sizeCategory

    @ScaledMetric var verticalPadding = 10
    @ScaledMetric var verticalHeight = 75
    let chartItem: ChartItem

    var body: some View {
        HStack(alignment: .top, spacing: -20) {
            deckColorCapsule
            VStack(alignment: .leading, spacing: 5) {
                deckName
                HStack(spacing: 20) {
                    flashcardCountLabel
                    percentCorrectLabel
                }
            }
            .font(.customSubheadline)
        }
        .frame(maxWidth: .infinity, maxHeight: verticalHeight, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, verticalPadding)
        .background(LinearGradient(
            colors: [chartItem.primaryColor.opacity(0.3), .white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .background(.white)
        .clipDefaultShape()
        .overlay {
            RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                .stroke(chartItem.primaryColor, lineWidth: 2)
        }
    }

    private var deckColorCapsule: some View {
        Capsule()
            .rotation(Angle(degrees: 90), anchor: .topLeading)
            .frame(width: 50, height: 5)
            .foregroundStyle(chartItem.primaryColor)
    }

    private var deckName: some View {
        Text(chartItem.deck.name)
            .fontWeight(.semibold)
            .frame(alignment: .leading)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .font(.customSubheadline)
    }

    private var flashcardCountLabel: some View {
        HStack(alignment: .top, spacing: 2.5) {
            Image(systemName: ContentConstants.Symbols.flashcard)
                .symbolVariant(.fill)
                .foregroundStyle(chartItem.primaryColor)
            Text("\(chartItem.flashcardCount)")
        }
    }

    private var percentCorrectLabel: some View {
        HStack(alignment: .top, spacing: 2.5) {
            Image(systemName: "hand.thumbsup")
                .symbolVariant(.fill)
                .foregroundStyle(chartItem.primaryColor)
            Text(String(format: "%.0f%%", chartItem.percentCorrect))
        }
    }
}

#if DEBUG
#Preview {
    HStack {
        ChartItemDisplay(chartItem: ChartItem.sampleArray[0])
    }
}
#endif
