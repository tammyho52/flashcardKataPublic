//
//  TrackerView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View displays review session metrics, allowing users to track their progress.

import SwiftUI

struct TrackerScreen: View {
    @ObservedObject var viewModel: TrackerViewModel
    @State private var isLoading: Bool = false

    let defaultButtonAction: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isGuestUser() {
                    GuestDefaultScreen(
                        guestViewType: .tracker,
                        buttonAction: viewModel.navigateToSignInWithoutAccount
                    )
                    .applyColoredNavigationBarStyle(
                        backgroundGradientColors: Tab.tracker.backgroundGradientColors,
                        disableBackgroundColor: true
                    )
                } else if isLoading {
                    FullScreenProgressScreen()
                        .applyColoredNavigationBarStyle(
                            backgroundGradientColors: Tab.tracker.backgroundGradientColors,
                            disableBackgroundColor: true
                        )
                        .edgesIgnoringSafeArea(.bottom)
                } else {
                    TrackerSummaryView(viewModel: viewModel)
                        .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.tracker.backgroundGradientColors)
                }
            }
            .navigationTitle("Tracker")
            .onAppear {
                if !viewModel.isGuestUser() {
                    isLoading = true
                    Task {
                        await viewModel.checkForReviewSessionSummaries()
                        if viewModel.hasReviewSessionSummaries {
                            try await viewModel.loadTrackerSummaryViewData()
                        }
                        isLoading = false
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    TrackerScreen(viewModel: TrackerViewModel(databaseManager: MockDatabaseManager()), defaultButtonAction: {})
}
#endif
