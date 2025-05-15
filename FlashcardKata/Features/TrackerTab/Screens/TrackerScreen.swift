//
//  TrackerView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view responsible for displaying review session metrics, allowing users to track their progress.

import SwiftUI

/// A view that displays the review session tracker screen.
struct TrackerScreen: View {
    // MARK: - Properties
    @ObservedObject var viewModel: TrackerViewModel
    @MainActor @State private var viewState: ViewState = .progress
    @State private var viewType: TrackerViewType = .dailySummary
    
    let defaultButtonAction: () -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                switch viewState {
                // Guest User
                case .guest:
                    GuestDefaultScreen(
                        guestViewType: .tracker,
                        buttonAction: viewModel.navigateToSignInWithoutAccount
                    )
                // Loading Screen
                case .progress:
                    FullScreenProgressScreen()
                        .edgesIgnoringSafeArea(.bottom)
                // Tracker Summary
                case .trackerSummary:
                    TrackerSummaryView(
                        viewModel: viewModel,
                        viewType: $viewType
                    )
                }
            }
            .navigationTitle("Tracker")
            .applyColoredNavigationBarStyle(
                backgroundGradientColors: Tab.tracker.backgroundGradientColors,
                disableBackgroundColor: viewState != .trackerSummary
            )
            .onAppear {
                guard !viewModel.isGuestUser() else {
                    viewState = .guest
                    return
                }
                Task {
                    if await viewModel.hasReviewSessionSummaries() {
                        await viewModel.loadTrackerSummaryViewData()
                    }
                    viewState = .trackerSummary
                }
            }
        }
    }
}

// MARK: - View State
/// Enum that represents the different states of the Tracker screen.
private enum ViewState {
    case guest
    case progress
    case trackerSummary
}

// MARK: - Preview
#if DEBUG
#Preview {
    TrackerScreen(
        viewModel: TrackerViewModel(databaseManager: MockDatabaseManager()),
        defaultButtonAction: {}
    )
}
#endif
