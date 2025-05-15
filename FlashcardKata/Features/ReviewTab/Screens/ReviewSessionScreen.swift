//
//  ReviewSessionScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for managing and displaying the review session screens,
//  including the flashcards, score transitions, and session metrics.

import SwiftUI
import Combine

/// View for managing the review session screens.
struct ReviewSessionScreen: View {
    // MARK: - Review Session State Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReviewViewModel
    @State private var reviewViewState: ReviewViewState = .isLoading
    @State private var flashcardIndex: Int = 0
    @State private var showExitAlert: Bool = false
    @State private var isFirstTime: Bool = true
    
    // MARK: - Streak Review Session Properties
    @State private var currentStreak: Int = 0
    
    // MARK: - Timed Review Session Properties
    @State private var timer: AnyCancellable? // Timer for countdown in timed reviews.
    @State private var secondsRemaining: Int = 60
    @State private var timerPublisher: Publishers.Autoconnect<Timer.TimerPublisher>? // Publisher to trigger the countdown.

    let exitAction: () -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Group {
                switch reviewViewState {
                // Loading state
                case .isLoading:
                    FullScreenProgressScreen()
                        .edgesIgnoringSafeArea(.bottom)
                // Flashcard review state
                case .flashcard:
                    ReviewFlashcardCardsView(
                        viewModel: viewModel,
                        viewState: $reviewViewState,
                        currentStreak: $currentStreak,
                        secondsRemaining: $secondsRemaining,
                        flashcardIndex: $flashcardIndex,
                        saveReviewSession: viewModel.saveReviewSessionSummary
                    )
                    .transition(.opacity.combined(with: .scale))
                // Correct score transition state
                case .correctMessage:
                    ScoreTransitionScreen(reviewViewState: $reviewViewState, scoreType: .correct)
                        .transition(.scale)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("correctScoreTransitionScreen")
                // Incorrect score transition state
                case .incorrectMessage:
                    ScoreTransitionScreen(reviewViewState: $reviewViewState, scoreType: .incorrect)
                        .transition(.scale)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("incorrectScoreTransitionScreen")
                // Review session ended summary state
                case .reviewEnded:
                    ReviewSessionMetricsScreen(
                        reviewSessionSummary: viewModel.reviewSessionSummary,
                        completedReviewModeMessage: viewModel.getCompletionReviewMessage()
                    )
                    .transition(.scale)
                    .accessibilityIdentifier("reviewSessionMetricsScreen")
                }
            }
            .navigationTitle("\(viewModel.reviewMode.description) Kata")
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarExitButton(action: {
                    if reviewViewState == .reviewEnded {
                        // Immediately exit the review session if it has ended.
                        exitReviewSessionActions()
                    } else {
                        // Show exit confirmation alert as review sessions are not saved.
                        showExitAlert = true
                    }
                })
            }
            .applyClearNavigationBarStyle()
        }
        .onAppear {
            Task {
                if isFirstTime {
                    // Load the initial data for the review session.
                    try await viewModel.loadInitialData()
                    
                    // Check if there are flashcards to review.
                    guard viewModel.flashcardDisplayModels.count > 0 else {
                        dismiss()
                        return
                    }
                    // Start the review session.
                    reviewViewState = .flashcard
                    
                    // Set timed review session time and start timer if applicable.
                    if viewModel.reviewMode == .timed,
                        let totalSessionTime = viewModel.reviewSettings.sessionTime {
                        secondsRemaining = totalSessionTime.seconds
                        startTimer()
                    }
                }
            }
        }
        // Exit confirmation dialog as review sessions that have not ended are not saved.
        .confirmationDialog("Are you sure you want to exit?", isPresented: $showExitAlert, titleVisibility: .visible) {
            Button("Exit Kata Review", role: .destructive) {
                exitReviewSessionActions()
            }
        }
    }
    
    // MARK: - Private Methods
    /// Start the timer for Timed review sessions.
    private func startTimer() {
        // Initialize countdown timer for timed review sessions.
        timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
        // Use the timer publisher to update the seconds remaining.
        timer = timerPublisher?.sink { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer?.cancel()
                timer = nil
            }
        }
    }
    
    /// Exit review session and reset view model.
    private func exitReviewSessionActions() {
        exitAction()
        viewModel.shouldReset = true
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    @Previewable @Environment(\.font) var font
    let viewModel: ReviewViewModel = {
        let viewModel = ReviewViewModel(databaseManager: MockDatabaseManager())
        viewModel.reviewSettings.selectedFlashcardIDs = Set(Flashcard.sampleFlashcardArray.map(\.id))
        return viewModel
    }()
    ReviewSessionScreen(viewModel: viewModel, exitAction: {})
        .environment(\.font, Font.customBody)
}
#endif
