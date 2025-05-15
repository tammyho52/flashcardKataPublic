//
//  ReviewFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays the review flashcard, progress bar, and score bar for a review session.

import SwiftUI

/// A view for managing and displaying the review flashcard interface.
struct ReviewFlashcardCardsView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ReviewViewModel
    @State private var progressValue: Double = 0 // The current progress value for the progress bar.
    @MainActor @State private var isSaving: Bool = false
    @Binding var viewState: ReviewViewState // The current state of the review session for managing transitions.
    @Binding var currentStreak: Int // Used for streak review mode.
    @Binding var secondsRemaining: Int // Used for timed review session.
    @Binding var flashcardIndex: Int // The index of the current flashcard being displayed.

    let saveReviewSession: () async throws -> Void
    
    private var flashcardCount: Int {
        viewModel.flashcardDisplayModels.count
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            ReviewProgressBar(
                currentFlashcardIndex: $flashcardIndex,
                totalCardCount: flashcardCount
            )
            
            Spacer()
            
            DraggableFlashcardView(
                viewState: $viewState,
                flashcardDisplayModel: viewModel.flashcardDisplayModels[flashcardIndex],
                reviewSettings: viewModel.reviewSettings,
                correctScoreAction: correctScoreAction,
                incorrectScoreAction: incorrectScoreAction
            )
            .padding(.horizontal, 10)
            .tag(flashcardIndex)
            .accessibilityIdentifier("reviewSessionFlashcardView_\(flashcardIndex)")
            
            Spacer()
            
            ScoreBarView(
                correctScore: $viewModel.correctScore,
                incorrectScore: $viewModel.incorrectScore,
                reviewMode: $viewModel.reviewMode,
                currentStreak: $currentStreak,
                highStreak: $viewModel.highStreak,
                targetCorrectCount: $viewModel.reviewSettings.targetCorrectCount,
                secondsRemaining: $secondsRemaining
            )
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .applyOverlayProgressScreen(isViewDisabled: $isSaving)
        .onChange(of: secondsRemaining) {
            // Applicable only for Timed Review Session
            if secondsRemaining == 0 {
                withAnimation {
                    onTimerEnded()
                }
            }
        }
    }

    // MARK: - Private Methods
    /// Ends the review session and saves the summary when timer ends.
    private func onTimerEnded() {
        viewModel.isTimerEnded = true
        endAndSaveReviewSession()
    }
    
    /// Ends the review session, saves the summary, and changes the view state to review ended.
    private func endAndSaveReviewSession() {
        isSaving = true
        Task {
            try await viewModel.saveReviewSessionSummary()
            withAnimation {
                viewState = .reviewEnded
                isSaving = false
            }
        }
    }

    /// Processes correct score when the user answers correctly.
    private func correctScoreAction() {
        Task {
            // Adds correct score to the review session.
            viewModel.addScore()
            
            // Adds flashcard ID to the list of reviewed flashcards.
            await viewModel.addReviewedFlashcardID(
                id: viewModel.flashcardDisplayModels[flashcardIndex].flashcard.id,
                isCorrect: true
            )
            
            // Increments current streak if review mode is streak.
            if viewModel.reviewMode == .streak {
                currentStreak += 1
                // Sets current streak as new high streak if current streak is new high.
                if currentStreak > viewModel.highStreak {
                    viewModel.highStreak = currentStreak
                }
            }
            
            // If target review mode, checks if current correct score equals target correct.
            if viewModel.reviewMode == .target {
                // Completes review session once correct score equals target correct.
                if viewModel.correctScore == viewModel.reviewSettings.targetCorrectCount {
                    endAndSaveReviewSession()
                    return
                }
            }
            
            // Checks flashcard count and ends review session if current flashcard is the last flashcard.
            if flashcardIndex + 1 < flashcardCount {
                withAnimation {
                    flashcardIndex += 1
                    viewState = .correctMessage
                }
            } else {
                endAndSaveReviewSession()
            }
        }
    }
    
    /// Processes incorrect score when the user answers incorrectly.
    private func incorrectScoreAction() {
        Task {
            // Adds incorrect score to the review session.
            viewModel.subtractScore()
            
            // Adds flashcard ID to the list of reviewed flashcards.
            await viewModel.addReviewedFlashcardID(
                id: viewModel.flashcardDisplayModels[flashcardIndex].flashcard.id,
                isCorrect: false
            )
            // If streak review mode, sets current streak to 0.
            if viewModel.reviewMode == .streak {
                currentStreak = 0
            }
            // Checks flashcard count and ends review session if current flashcard is the last flashcard.
            if flashcardIndex + 1 < flashcardCount {
                withAnimation {
                    flashcardIndex += 1
                    viewState = .incorrectMessage
                }
            } else {
                endAndSaveReviewSession()
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let viewModel: ReviewViewModel = {
        let viewModel = ReviewViewModel(databaseManager: MockDatabaseManager())
        viewModel.flashcardDisplayModels = FlashcardDisplayModel.sampleArray
        return viewModel
    }()

    ReviewFlashcardCardsView(
        viewModel: viewModel,
        viewState: .constant(.flashcard),
        currentStreak: .constant(0),
        secondsRemaining: .constant(60),
        flashcardIndex: .constant(0),
        saveReviewSession: {}
    )
}
#endif
