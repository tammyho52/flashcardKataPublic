//
//  ReviewOverviewScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view for handling study mode selection.

import SwiftUI

/// A view for managing the study mode selection process.
struct ReviewOverviewScreen: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ReviewViewModel
    @State private var viewState: ViewState = .loading
    @State private var showReviewSettingsScreen = false

    let getStartedButtonAction: () -> Void // Action to perform when user has no flashcards in Empty Screen.

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                switch viewState {
                // Guest user view
                case .guest:
                    GuestDefaultScreen(
                        guestViewType: .kata,
                        buttonAction: viewModel.navigateToSignInWithoutAccount
                    )
                // Loading view
                case .loading:
                    FullScreenProgressScreen()
                        .edgesIgnoringSafeArea(.bottom)
                // No flashcards available view
                case .empty:
                    DefaultEmptyScreen(
                        defaultEmptyViewType: .getStarted,
                        buttonAction: getStartedButtonAction
                    )
                // Review modes selection view, when flashcards are available
                case .reviewModes:
                    ReviewModeSelectionView(
                        selectedReviewMode: $viewModel.reviewMode,
                        navigateToReviewSettingsView: {
                            showReviewSettingsScreen = true
                        }
                    )
                    .accessibilityIdentifier("reviewTabScreen")
                    .navigationDestination(isPresented: $showReviewSettingsScreen) {
                        ReviewSettingsScreen(
                            viewModel: viewModel,
                            showReviewSettingsScreen: $showReviewSettingsScreen
                        )
                    }
                }
            }
            .navigationTitle("Kata Review")
            .applyColoredNavigationBarStyle(
                backgroundGradientColors: Tab.kata.backgroundGradientColors,
                disableBackgroundColor: viewState != .reviewModes
            )
            .onAppear {
                guard !viewModel.isGuestUser() else {
                    viewState = .guest
                    return
                }
                
                Task {
                    // Check if the user has flashcards
                    await viewModel.checkForFlashcards()
                    
                    // Resets view model after a review session
                    if viewModel.shouldReset {
                        viewModel.resetAllValues()
                        viewModel.shouldReset = false
                    }
                    
                    // Update view state based on flashcard availability
                    viewState = viewModel.hasFlashcards ? .reviewModes : .empty
                }
            }
        }
    }
}

// MARK: - ViewState
/// An enum representing the different states of the view.
private enum ViewState {
    case guest
    case loading
    case empty
    case reviewModes
}

// MARK: - Preview
#if DEBUG
#Preview {
    return ReviewOverviewScreen(
        viewModel: ReviewViewModel(databaseManager: MockDatabaseManager()),
        getStartedButtonAction: {}
    )
}
#endif
