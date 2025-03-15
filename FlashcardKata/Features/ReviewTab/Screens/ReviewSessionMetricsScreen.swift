//
//  ReviewSessionMetricsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a review session summary screen with key metrics after a review session is completed.

import SwiftUI

struct ReviewSessionMetricsScreen: View {
    @State private var isAnimated: Bool = false
    let reviewSessionSummary: ReviewSessionSummary
    let completedReviewModeMessage: String

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                VStack(alignment: .center, spacing: 25) {
                    completedTitle
                        .padding(.vertical)
                    HStack {
                        decksCompletedCard
                        flashcardsCompletedCard
                    }
                    scoreSummary
                        .padding(.vertical)
                }
                .padding()
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .background(Color.customAccent3)
                .clipDefaultShape()
                .padding(10)
                .background(.white)
                .clipDefaultShape()
                .applyCoverShadow()

                reviewModeMetrics
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
        .scaleEffect(isAnimated ? 1 : 0.8)
        .opacity(isAnimated ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7)) {
                isAnimated = true
            }
        }
    }

    // MARK: - Child Views
    var completedTitle: some View {
        Text("Review Kata Completed")
            .font(.customTitle3)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var decksCompletedCard: some View {
        MetricCard(
            number: reviewSessionSummary.numberOfDecks,
            metric: "Decks",
            imageName: ContentConstants.Symbols.deck,
            imageColor: Color.customSecondary,
            backgroundColor: .white.opacity(0.8)
        )
    }

    var flashcardsCompletedCard: some View {
        MetricCard(
            number: reviewSessionSummary.numberOfFlashcards,
            metric: "Flashcards",
            imageName: ContentConstants.Symbols.flashcard,
            imageColor: Color.customSecondary,
            backgroundColor: .white.opacity(0.8)
        )
    }

    var scoreSummary: some View {
        ScoreSummaryBox(
            correctScore: reviewSessionSummary.correctScore,
            incorrectScore: reviewSessionSummary.incorrectScore
        )
    }

    var reviewModeMetrics: some View {
        HStack {
            Image(systemName: reviewSessionSummary.reviewMode.symbolName)
                .padding(.horizontal, 5)
                .font(.title3)
            Text(completedReviewModeMessage)
                .padding(.horizontal, 5)
        }
        .font(.customHeadline)
        .fontWeight(.semibold)
        .padding()
        .frame(maxWidth: . infinity)
        .background(.lightPink)
        .clipShape(Capsule())
        .padding(.horizontal)
        .applyCoverShadow()
    }
}

#if DEBUG
#Preview {
    ReviewSessionMetricsScreen(
        reviewSessionSummary: ReviewSessionSummary.sampleArray[0],
        completedReviewModeMessage: "Great Job!"
    )
    .padding()
}

#Preview {
    ReviewSessionMetricsScreen(
        reviewSessionSummary: ReviewSessionSummary.sampleArray[1],
        completedReviewModeMessage: "Great Job!"
    )
    .padding()
}

#Preview {
    ReviewSessionMetricsScreen(
        reviewSessionSummary: ReviewSessionSummary.sampleArray[2],
        completedReviewModeMessage: "Great Job!"
    )
    .padding()
}

#Preview {
    ReviewSessionMetricsScreen(
        reviewSessionSummary: ReviewSessionSummary.sampleArray[3],
        completedReviewModeMessage: "Great Job!"
    )
    .padding()
}
#endif
