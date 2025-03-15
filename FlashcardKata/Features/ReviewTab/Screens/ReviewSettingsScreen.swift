//
//  ReviewSettingsScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Controls the settings for review session.

import SwiftUI

struct ReviewSettingsScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReviewViewModel
    @State private var showSelectDecksView: Bool = false
    @State private var startStudySession: Bool = false
    @Binding var showReviewSettingsScreen: Bool

    var body: some View {
        NavigationStack {
            List {
                ReviewSettingsSections(
                    showSelectDeckView: $showSelectDecksView,
                    reviewSettings: $viewModel.reviewSettings,
                    clearSelectedFlashcardIDs: viewModel.clearSelectedFlashcardIDs
                )
                .listRowBackground(Color.clear)

                // Target Mode Section (visible if selected review mode is "Target")
                if viewModel.reviewMode == .target {
                    Section("Target Mode") {
                        labeledTargetModeCorrectPicker
                    }
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                // Timed Mode Section (visible if selected review mode is "Timed")
                if viewModel.reviewMode == .timed {
                    Section("Timed Mode") {
                        labeledTimedModePicker
                    }
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .navigationTitle("Review Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.kata.backgroundGradientColors)
            .sheet(isPresented: $showSelectDecksView) {
                ReviewSelectDecksView(viewModel: viewModel, showSelectDecksView: $showSelectDecksView)
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $startStudySession) {
                ReviewSessionScreen(viewModel: viewModel, exitAction: exitToReviewOverviewScreen)
            }
            .toolbar {
                toolbarBackButton {
                    dismiss()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        startStudySession = true
                        viewModel.reviewSessionSummary.startDate = Date()
                    } label: {
                        Image(systemName: "play.fill")
                            .fontWeight(.semibold)
                            .font(.title3)
                            .tint(Color.customSecondary)
                    }
                    .disabled(isStartStudySessionDisabled)
                }
            }
        }
    }

    // MARK: - Helper methods
    private func exitToReviewOverviewScreen() {
        Task {
            startStudySession = false
            while startStudySession == true {
                await Task.yield()
            }
            await MainActor.run {
                showReviewSettingsScreen = false
            }
        }
    }

    var labeledTargetModeCorrectPicker: some View {
        HStack {
            Label {
                Text("Maximum Target Correct Count")
            } icon: {
                Image(systemName: viewModel.reviewMode.symbolName)
                    .foregroundStyle(DesignConstants.Colors.iconSecondary)
            }
            Spacer()
            Picker("Maximum Target Count", selection: $viewModel.reviewSettings.targetCorrectCount) {
                ForEach(Array(stride(from: 10, to: 101, by: 10)), id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
            .labelsHidden()
        }
    }

    var labeledTimedModePicker: some View {
        HStack {
            Label {
                Text("Maximum Kata Review Time")
            } icon: {
                Image(systemName: viewModel.reviewMode.symbolName)
                    .foregroundStyle(DesignConstants.Colors.iconSecondary)
            }
            Spacer()
            Picker("Maximum Kata Review Time", selection: $viewModel.reviewSettings.sessionTime) {
                ForEach(SessionTime.allCases) { sessionTime in
                    Text("\(sessionTime.rawValue)").tag(sessionTime)
                }
            }
            .labelsHidden()
        }
    }

    private var isStartStudySessionDisabled: Bool {
        return viewModel.reviewSettings.selectedFlashcardMode == .custom
                && viewModel.reviewSettings.selectedFlashcardIDs.isEmpty
    }
}

#if DEBUG
#Preview {
    let viewModel: ReviewViewModel = {
        let viewModel = ReviewViewModel(databaseManager: MockDatabaseManager())
        viewModel.reviewSettings.selectedFlashcardIDs = Set(Flashcard.sampleFlashcardArray.map(\.id))
        return viewModel
    }()

    ReviewSettingsScreen(viewModel: viewModel, showReviewSettingsScreen: .constant(true))
}
#endif
