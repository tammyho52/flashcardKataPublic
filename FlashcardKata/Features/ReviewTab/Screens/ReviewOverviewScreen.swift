//
//  StudyView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for handling study mode selection.

import SwiftUI

struct ReviewOverviewScreen: View {
    @ObservedObject var viewModel: ReviewViewModel
    @State private var showReviewSettingsScreen = false
    @State private var isLoading = false

    let defaultButtonAction: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isGuestUser() {
                    GuestDefaultScreen(
                        guestViewType: .kata,
                        buttonAction: viewModel.navigateToSignInWithoutAccount
                    )
                    .applyColoredNavigationBarStyle(
                        backgroundGradientColors: Tab.kata.backgroundGradientColors,
                        disableBackgroundColor: true
                    )
                } else if isLoading {
                    FullScreenProgressScreen()
                        .applyColoredNavigationBarStyle(
                            backgroundGradientColors: Tab.kata.backgroundGradientColors,
                            disableBackgroundColor: true
                        )
                        .edgesIgnoringSafeArea(.bottom)
                } else if !viewModel.hasFlashcards {
                    DefaultEmptyScreen(defaultEmptyViewType: .getStarted, buttonAction: defaultButtonAction)
                        .applyColoredNavigationBarStyle(
                            backgroundGradientColors: Tab.kata.backgroundGradientColors,
                            disableBackgroundColor: true
                        )
                } else {
                    ReviewModeSelectionView(
                        selectedReviewMode: $viewModel.reviewMode,
                        navigateToReviewSettingsView: {
                            showReviewSettingsScreen = true
                        }
                    )
                    .navigationDestination(isPresented: $showReviewSettingsScreen) {
                        ReviewSettingsScreen(
                            viewModel: viewModel,
                            showReviewSettingsScreen: $showReviewSettingsScreen
                        )
                    }
                    .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.kata.backgroundGradientColors)
                }
            }
            .navigationTitle("Kata Review")
            .onAppear {
                // Fetch flashcards and handle reset logic when the view appears.
                if !viewModel.isGuestUser() {
                    Task {
                        isLoading = true
                        await viewModel.checkForFlashcards()
                        if viewModel.shouldReset {
                            viewModel.resetAllValues()
                            viewModel.shouldReset = false
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
    return ReviewOverviewScreen(
        viewModel: ReviewViewModel(databaseManager: MockDatabaseManager()),
        defaultButtonAction: {}
    )
}
#endif
