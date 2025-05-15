//
//  TrackerSummaryView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view is responsible for displaying review session metrics, allowing users to track their progress.

import SwiftUI

/// A view that summarizes the review session metrics for a selected date.
struct TrackerSummaryView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: TrackerViewModel
    @State private var isLoading: Bool = false
    @Binding var viewType: TrackerViewType

    // MARK: - Body
    var body: some View {
        Group {
            switch viewType {
            // Displays daily summary statistics
            case .dailySummary:
                DailySummaryView(viewModel: viewModel, isLoading: $isLoading)
            // Displays deck level statistics
            case .deckStatistics:
                DeckStatisticsView(
                    isLoading: $isLoading,
                    fetchDeckReviewStatistics: viewModel.fetchDeckReviewStatistics,
                    fetchFlashcardReviewStatistics: viewModel.fetchFlashcardReviewStatistics
                )
            }
        }
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                trackerModeMenu
            }
        }
    }
    
    // MARK: - Private Views
    private var trackerModeMenu: some View {
        Menu {
            ForEach(TrackerViewType.allCases, id: \.self) { viewType in
                Button {
                    self.viewType = viewType
                } label: {
                    Text(viewType.description)
                }
            }
        } label: {
            Image(systemName: ContentConstants.Symbols.menu)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let viewModel: TrackerViewModel = {
        let vm = TrackerViewModel(databaseManager: MockDatabaseManager())
        vm.cardsLearnedCount = 10
        vm.streakCount = 5
        vm.timeStudied = "1:30"
        vm.reviewSessionSummaries = ReviewSessionSummary.sampleArray
        vm.chartItems = ChartItem.sampleArray
        return vm
    }()
    
    NavigationStack {
        TrackerSummaryView(
            viewModel: viewModel,
            viewType: .constant(.dailySummary)
        )
        .navigationTitle("Tracker")
        .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.tracker.backgroundGradientColors)
    }
}
#endif
