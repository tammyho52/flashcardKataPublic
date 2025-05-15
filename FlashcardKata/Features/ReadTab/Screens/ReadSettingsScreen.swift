//
//  ReadSettingsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view for managing read settings, including flashcard selection and display options.

import SwiftUI

/// A  view for configuring read settings.
struct ReadSettingsScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReadViewModel
    @State private var reviewSettings: ReviewSettings = ReviewSettings()
    @MainActor @State private var isSaving: Bool = false
    @State private var showSelectDeckView: Bool = false // Flag to show the deck selection view

    let loadFlashcards: () async -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                ReviewSettingsSections(
                    showSelectDeckView: $showSelectDeckView,
                    reviewSettings: $reviewSettings,
                    clearSelectedFlashcardIDs: viewModel.clearSelectedFlashcardIDs
                )
            }
            .listStyle(.inset)
            .applyOverlayProgressScreen(isViewDisabled: $isSaving)
            .navigationTitle("Read Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $showSelectDeckView) {
                ReadSelectDecksScreen(
                    viewModel: viewModel,
                    selectedFlashcardIDs: $reviewSettings.selectedFlashcardIDs,
                    showSelectDeckView: $showSelectDeckView
                )
            }
            .onChange(of: showSelectDeckView) { _, newValue in
                if newValue {
                    viewModel.reviewSettings = reviewSettings
                }
            }
            .onAppear {
                reviewSettings = viewModel.reviewSettings
            }
            .toolbar {
                toolbarBackButton(isDisabled: isSaving) {
                    dismiss()
                }
                toolbarTextButton(
                    isDisabled: isSaving,
                    action: saveReviewSettings,
                    text: "Save",
                    placement: .topBarTrailing
                )
            }
        }
    }
    
    // MARK: - Private Methods
    private func saveReviewSettings() {
        isSaving = true
        Task {
            viewModel.reviewSettings = reviewSettings
            await loadFlashcards() // Load flashcards after saving settings
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ReadSettingsScreen(
        viewModel: ReadViewModel(databaseManager: MockDatabaseManager()),
        loadFlashcards: {}
    )
    .font(.customBody)
}
#endif
