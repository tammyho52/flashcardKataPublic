//
//  ReviewSessionMetricsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays a summary of the review session after completion,
//  including key metrics such as the number of decks and flashcards completed,
//  the score summary, and the review mode message.

import SwiftUI

/// A view that presents a summary of the completed review session.
struct ReviewSessionMetricsScreen: View {
    // MARK: - Properties
    @State private var isAnimated: Bool = false
    
    let reviewSessionSummary: ReviewSessionSummary
    let completedReviewModeMessage: String

    // MARK: - Body
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

                reviewModeMetrics // Changes based on the review mode
            }
            .padding(20)
        }
        .accessibilityIdentifier("reviewSessionMetricsScreen")
        .scrollIndicators(.hidden)
        .scaleEffect(isAnimated ? 1 : 0.8)
        .opacity(isAnimated ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7)) {
                isAnimated = true
            }
        }
    }

    // MARK: - Private Views
    /// A title view for the completed review session.
    private var completedTitle: some View {
        Text("Review Kata Completed")
            .font(.customTitle3)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    /// A card displaying the number of decks completed.
    private var decksCompletedCard: some View {
        MetricCard(
            number: reviewSessionSummary.numberOfDecks,
            metric: reviewSessionSummary.numberOfDecks == 1 ? "Deck" : "Decks",
            imageName: ContentConstants.Symbols.deck,
            imageColor: Color.customSecondary,
            backgroundColor: .white.opacity(0.8)
        )
    }

    /// A card displaying the number of flashcards completed.
    private var flashcardsCompletedCard: some View {
        MetricCard(
            number: reviewSessionSummary.numberOfFlashcards,
            metric: reviewSessionSummary.numberOfFlashcards == 1 ? "Flashcard" : "Flashcards",
            imageName: ContentConstants.Symbols.flashcard,
            imageColor: Color.customSecondary,
            backgroundColor: .white.opacity(0.8)
        )
    }

    /// A summary box displaying the score of correct and incorrect answers.
    private var scoreSummary: some View {
        ScoreSummaryBox(
            correctScore: reviewSessionSummary.correctScore,
            incorrectScore: reviewSessionSummary.incorrectScore
        )
    }

    /// A view that displays the review mode metrics.
    private var reviewModeMetrics: some View {
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

// MARK: - Preview
#if DEBUG
#Preview {
    ReviewSessionMetricsScreen(
        reviewSessionSummary: ReviewSessionSummary.sampleArray[0],
        completedReviewModeMessage: "Great Job!"
    )
    .padding()
}
#endif
