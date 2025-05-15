//
//  ReviewSettingsScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that controls the settings for a review session.

import SwiftUI

/// A view for managing review session settings.
struct ReviewSettingsScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReviewViewModel
    @State private var showSelectDecksView: Bool = false
    @State private var startStudySession: Bool = false
    @Binding var showReviewSettingsScreen: Bool

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // Review settings sections including flashcard selection and review settings
                ReviewSettingsSections(
                    showSelectDeckView: $showSelectDecksView,
                    reviewSettings: $viewModel.reviewSettings,
                    clearSelectedFlashcardIDs: viewModel.clearSelectedFlashcardIDs
                )
                .listRowBackground(Color.clear)

                // Show target mode section if selected review mode is "Target"
                if viewModel.reviewMode == .target {
                    Section("Target Mode") {
                        labeledTargetModeCorrectPicker
                    }
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                // Show timed mode section if selected review mode is "Timed"
                if viewModel.reviewMode == .timed {
                    Section("Timed Mode") {
                        labeledTimedModePicker
                    }
                    .listSectionSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .accessibilityIdentifier("reviewSessionSettingsScreen")
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .navigationTitle("Review Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showSelectDecksView) {
                ReviewSelectDecksScreen(viewModel: viewModel, showSelectDecksView: $showSelectDecksView)
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $startStudySession) {
                ReviewSessionScreen(
                    viewModel: viewModel,
                    exitAction: exitToReviewOverviewScreen
                )
            }
            .toolbar {
                toolbarBackButton {
                    dismiss()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        startStudySession = true
                        // Set the start date for the review session summary
                        viewModel.reviewSessionSummary.startDate = Date()
                    } label: {
                        Image(systemName: "play.fill")
                            .fontWeight(.semibold)
                            .font(.title3)
                    }
                    .disabled(isStartStudySessionDisabled)
                    .accessibilityIdentifier("startReviewSessionButton")
                }
            }
            .applyColoredNavigationBarStyle(
                backgroundGradientColors: Tab.kata.backgroundGradientColors
            )
        }
    }

    // MARK: - Private methods
    /// Exits to the review overview screen after the study session ends.
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
    
    private var isStartStudySessionDisabled: Bool {
        return viewModel.reviewSettings.selectedFlashcardMode == .custom
                && viewModel.reviewSettings.selectedFlashcardIDs.isEmpty
    }
    
    // MARK: - Private Views
    /// A label indicating the maximum target correct count for Target mode.
    private var labeledTargetModeCorrectPicker: some View {
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
    
    /// A label indicating the maximum session time for Timed mode.
    private var labeledTimedModePicker: some View {
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
}

// MARK: - Preview
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
