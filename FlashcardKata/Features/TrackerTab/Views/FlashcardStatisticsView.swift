//
//  FlashcardStatisticsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This view displays review statistics at the flashcard level for a specified deck.

import SwiftUI

/// A view that displays detailed review statistics for flashcards within a specific deck.
struct FlashcardStatisticsView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @MainActor @State private var isLoading: Bool = false
    @State private var flashcardReviewStatistics: [FlashcardReviewStatistics] = []
    
    let deckTitle: String
    let deckColor: Color
    let fetchFlashcardReviewStatistics: () async throws -> [FlashcardReviewStatistics]
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Empty state
            if flashcardReviewStatistics.isEmpty {
                SectionHeaderTitle(text: deckTitle)
                    .padding(.bottom, 20)
                Text("Deck contains no flashcards. No review statistics are currently available.")
                    .padding(.horizontal, 20)
            // Flashcard statistics view with data
            } else {
                FlashcardStatisticsListView(
                    flashcardReviewStatistics: $flashcardReviewStatistics,
                    deckTitle: deckTitle,
                    deckColor: deckColor
                )
            }
            Spacer()
        }
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarBackButton(isDisabled: false) { dismiss() }
        }
        .onAppear {
            isLoading = true
            Task {
                flashcardReviewStatistics = try await fetchFlashcardReviewStatistics()
                isLoading = false
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
// Preview with sample data
#Preview {
    NavigationStack {
        FlashcardStatisticsView(
            deckTitle: Deck.sampleDeck.name,
            deckColor: Deck.sampleDeck.theme.primaryColor,
            fetchFlashcardReviewStatistics: { return FlashcardReviewStatistics.sampleArray }
        )
    }
}

// Preview with no data
#Preview {
    NavigationStack {
        FlashcardStatisticsView(
            deckTitle: Deck.sampleDeck.name,
            deckColor: Deck.sampleDeck.theme.primaryColor,
            fetchFlashcardReviewStatistics: { return [] }
        )
    }
}
#endif
