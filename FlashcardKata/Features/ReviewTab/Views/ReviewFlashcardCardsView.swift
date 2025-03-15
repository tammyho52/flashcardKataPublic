//
//  ReviewFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays review flashcard, progress bar, and score bar based on review mode type.

import SwiftUI

struct ReviewFlashcardCardsView: View {
    @ObservedObject var viewModel: ReviewViewModel
    @State private var progressValue: Double = 0
    @State private var isSaving: Bool = false
    @Binding var viewState: ReviewViewState
    @Binding var currentStreak: Int
    @Binding var secondsRemaining: Int
    @Binding var flashcardIndex: Int

    let saveReviewSession: () async throws -> Void
    private var flashcardCount: Int {
        viewModel.flashcardDisplayModels.count
    }

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
            Spacer()
            ScoreBarView(
                correctScore: $viewModel.correctScore,
                incorrectScore: $viewModel.incorrectScore,
                currentStreak: $currentStreak,
                highStreak: $viewModel.highStreak,
                targetCorrectCount: $viewModel.reviewSettings.targetCorrectCount,
                reviewMode: $viewModel.reviewMode,
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

    // MARK: - Helper Methods
    private func onTimerEnded() {
        viewModel.isTimerEnded = true
        endAndSaveReviewSession()
    }

    private func endAndSaveReviewSession() {
        Task {
            isSaving = true
            try await viewModel.saveReviewSessionSummary()
            withAnimation {
                viewState = .reviewEnded
                isSaving = false
            }
        }
    }

    private func correctScoreAction() {
        Task {
            viewModel.addScore()
            await viewModel.addReviewedFlashcardID(
                id: viewModel.flashcardDisplayModels[flashcardIndex].flashcard.id,
                isCorrect: true
            )
            if viewModel.reviewMode == .streak {
                currentStreak += 1
                // Sets current streak as new high streak if current streak is new high.
                if currentStreak > viewModel.highStreak {
                    viewModel.highStreak = currentStreak
                }
            }
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

    private func incorrectScoreAction() {
        Task {
            viewModel.subtractScore()
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
