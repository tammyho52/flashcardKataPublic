//
//  ChartItemDisplay.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This component displays flashcard review metrics for a specified deck.

import SwiftUI

/// A view that displays flashcard review metrics, including the deck name, flashcard count, and percentage of correct answers.
struct ChartItemDisplay: View {
    // MARK: - Properties
    @Environment(\.sizeCategory) var sizeCategory
    @ScaledMetric var verticalPadding = 10
    @ScaledMetric var verticalHeight = 75
    
    let chartItem: ChartItem

    // MARK: - Body
    var body: some View {
        HStack(alignment: .top, spacing: -20) {
            deckColorCapsule // Decorative capsule representing the deck color
            
            // Deck metrics
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
    
    // MARK: - Private Views
    /// A decorative capsule representing the deck color.
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
            Image(systemName: ContentConstants.Symbols.correctScore)
                .symbolVariant(.fill)
                .foregroundStyle(chartItem.primaryColor)
            Text(String(format: "%.0f%%", chartItem.percentCorrect))
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    HStack {
        ChartItemDisplay(chartItem: ChartItem.sampleArray[0])
    }
}
#endif
