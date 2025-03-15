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

struct ReviewSessionScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReviewViewModel
    @State private var reviewViewState: ReviewViewState = .isLoading
    @State private var timer: AnyCancellable?
    @State private var secondsRemaining: Int = 60
    @State private var currentStreak: Int = 0
    @State private var flashcardIndex: Int = 0
    @State private var showExitAlert: Bool = false
    @State private var isFirstTime: Bool = true

    let exitAction: () -> Void
    private let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            Group {
                switch reviewViewState {
                case .isLoading:
                    FullScreenProgressScreen()
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
                case .correctMessage:
                    ScoreTransitionScreen(reviewViewState: $reviewViewState, scoreType: .correct)
                        .transition(.scale)
                case .incorrectMessage:
                    ScoreTransitionScreen(reviewViewState: $reviewViewState, scoreType: .incorrect)
                        .transition(.scale)
                case .reviewEnded:
                    ReviewSessionMetricsScreen(
                        reviewSessionSummary: viewModel.reviewSessionSummary,
                        completedReviewModeMessage: viewModel.completedReviewModeMessage
                    )
                    .transition(.scale)
                }
            }
            .navigationTitle("\(viewModel.reviewMode.description) Kata")
            .applyClearNavigationBarStyle()
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarExitButton(action: { showExitAlert = true })
            }
        }
        .onAppear {
            Task {
                if isFirstTime {
                    try await viewModel.loadFlashcardDisplayModels()
                    guard viewModel.flashcardDisplayModels.count > 0 else {
                        dismiss()
                        return
                    }
                    reviewViewState = .flashcard
                    if viewModel.reviewMode == .timed, let totalSessionTime = viewModel.reviewSettings.sessionTime {
                        secondsRemaining = totalSessionTime.seconds
                        startTimer()
                    }
                }
            }
        }
        .confirmationDialog("Are you sure you want to exit?", isPresented: $showExitAlert, titleVisibility: .visible) {
            Button("Exit Kata Review", role: .destructive) {
                Task {
                    exitAction()
                    viewModel.shouldReset = true
                }
            }
        }
    }

    // Start the timer for Timed review sessions.
    private func startTimer() {
        guard timer == nil else { return }
        timer = timerPublisher.sink { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer?.cancel()
                timer = nil
            }
        }
    }
}

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
