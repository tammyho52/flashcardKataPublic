//
//  GeneralReviewView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI
import Combine

struct ReviewSessionScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ReviewViewModel
    @State var reviewViewState: ReviewViewState = .isLoading
    @State private var timer: AnyCancellable?
    @State private var secondsRemaining: Int = 60
    @State private var currentStreak: Int = 0
    @State var flashcardIndex: Int = 0
    @State var showExitAlert: Bool = false
    @State var isFirstTime: Bool = true
    
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
                        vm: vm,
                        viewState: $reviewViewState,
                        currentStreak: $currentStreak,
                        secondsRemaining: $secondsRemaining,
                        flashcardIndex: $flashcardIndex,
                        saveReviewSession: vm.saveReviewSessionSummary
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
                        reviewSessionSummary: vm.reviewSessionSummary,
                        completedReviewModeMessage: vm.completedReviewModeMessage
                    )
                    .transition(.scale)
                }
            }
            .navigationTitle("\(vm.reviewMode.description) Kata")
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
                    try await vm.loadFlashcardDisplayModels()
                    guard vm.flashcardDisplayModels.count > 0 else {
                        dismiss()
                        return
                    }
                    reviewViewState = .flashcard
                    if vm.reviewMode == .timed, let totalSessionTime = vm.reviewSettings.sessionTime {
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
                    vm.shouldReset = true
                }
            }
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = timerPublisher.sink { timestamp in
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
    let vm: ReviewViewModel = {
        let vm = ReviewViewModel(databaseManager: MockDatabaseManager())
        vm.reviewSettings.selectedFlashcardIDs = Set(Flashcard.sampleFlashcardArray.map(\.id))
        return vm
    }()
    ReviewSessionScreen(vm: vm, exitAction: {})
        .environment(\.font, Font.customBody)
}
#endif
