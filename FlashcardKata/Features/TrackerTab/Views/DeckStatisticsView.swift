//
//  DeckStatisticsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This view displays a list of deck statistics, allowing users to navigate to detailed flashcard statistics for each deck.

import SwiftUI

/// A view that displays deck statistics and allows navigation to flashcard statistics.
struct DeckStatisticsView: View {
    // MARK: - Properties
    @State private var selectedDeckReviewStatistics: DeckReviewStatistics?
    @State private var deckWithSubdecksReviewStatistics: [DeckReviewStatistics: [DeckReviewStatistics]] = [:]
    @State private var showNavigationDestination: Bool = false
    @MainActor @Binding var isLoading: Bool
    
    let fetchDeckReviewStatistics: () async throws -> [DeckReviewStatistics: [DeckReviewStatistics]]
    let fetchFlashcardReviewStatistics: (String) async throws -> [FlashcardReviewStatistics]
    
    // MARK: - Body
    var body: some View {
        DeckStatisticsListView(
            deckWithSubdecksReviewStatistics: $deckWithSubdecksReviewStatistics,
            onSelectDeckCell: onSelectDeckCell
        )
        .onAppear {
            isLoading = true
            Task {
                deckWithSubdecksReviewStatistics = try await fetchDeckReviewStatistics()
                isLoading = false
            }
        }
        .navigationDestination(isPresented: $showNavigationDestination) {
            if let selectedDeckReviewStatistics {
                FlashcardStatisticsView(
                    deckTitle: selectedDeckReviewStatistics.deckName,
                    deckColor: selectedDeckReviewStatistics.deckColor,
                    fetchFlashcardReviewStatistics: {
                        try await fetchFlashcardReviewStatistics(selectedDeckReviewStatistics.id)
                    }
                )
            }
        }
    }
    
    // MARK: - Private Methods
    /// Navigates to the detailed flashcard statistics view for the selected deck.
    private func onSelectDeckCell(deckReviewStatistics: DeckReviewStatistics) {
        selectedDeckReviewStatistics = deckReviewStatistics
        showNavigationDestination = true
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        DeckStatisticsView(
            isLoading: .constant(false),
            fetchDeckReviewStatistics: {
                return DeckReviewStatistics.sampleDeckWithSubdecksReviewStatistics
            },
            fetchFlashcardReviewStatistics: { _ in
                return FlashcardReviewStatistics.sampleArray
            }
        )
    }
}
#endif
