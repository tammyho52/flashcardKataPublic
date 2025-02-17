//
//  ReviewFlashcardView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReviewFlashcardCardsView: View {
    @ObservedObject var vm: ReviewViewModel
    @State private var progressValue: Double = 0
    @State private var isSaving: Bool = false
    @Binding var viewState: ReviewViewState
    @Binding var currentStreak: Int
    @Binding var secondsRemaining: Int
    @Binding var flashcardIndex: Int

    let saveReviewSession: () async throws -> Void
    private var flashcardCount: Int {
        vm.flashcardDisplayModels.count
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
                flashcardDisplayModel: vm.flashcardDisplayModels[flashcardIndex],
                reviewSettings: vm.reviewSettings,
                correctScoreAction: correctScoreAction,
                incorrectScoreAction: incorrectScoreAction
            )
            .padding(.horizontal, 10)
            .tag(flashcardIndex)
            Spacer()
            ScoreBarView(
                correctScore: $vm.correctScore,
                incorrectScore: $vm.incorrectScore,
                currentStreak: $currentStreak,
                highStreak: $vm.highStreak,
                targetCorrectCount: $vm.reviewSettings.targetCorrectCount,
                reviewMode: $vm.reviewMode,
                secondsRemaining: $secondsRemaining
            )
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .applyOverlayProgressScreen(isViewDisabled: $isSaving)
        .onChange(of: secondsRemaining) {
            if secondsRemaining == 0 {
                withAnimation {
                    onTimerEnded()
                }
            }
        }
    }
    
    private func onTimerEnded() {
        vm.isTimerEnded = true
        endAndSaveReviewSession()
    }
    
    private func endAndSaveReviewSession() {
        Task {
            isSaving = true
            try await vm.saveReviewSessionSummary()
            withAnimation {
                viewState = .reviewEnded
                isSaving = false
            }
        }
    }
    
    private func correctScoreAction() {
        Task {
            vm.addScore()
            await vm.addReviewedFlashcardID(id: vm.flashcardDisplayModels[flashcardIndex].flashcard.id, isCorrect: true)
            if vm.reviewMode == .streak {
                currentStreak += 1
                if currentStreak > vm.highStreak {
                    vm.highStreak = currentStreak
                }
            }
            if vm.reviewMode == .target {
                if vm.correctScore == vm.reviewSettings.targetCorrectCount {
                    endAndSaveReviewSession()
                    return
                }
            }
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
            vm.subtractScore()
            await vm.addReviewedFlashcardID(id: vm.flashcardDisplayModels[flashcardIndex].flashcard.id, isCorrect: false)
            if vm.reviewMode == .streak {
                currentStreak = 0
            }
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
    let vm: ReviewViewModel = {
        let vm = ReviewViewModel(databaseManager: MockDatabaseManager())
        vm.flashcardDisplayModels = FlashcardDisplayModel.sampleArray
        return vm
    }()
    
    ReviewFlashcardCardsView(
        vm: vm,
        viewState: .constant(.flashcard),
        currentStreak: .constant(0),
        secondsRemaining: .constant(60),
        flashcardIndex: .constant(0),
        saveReviewSession: {}
    )
}
#endif
