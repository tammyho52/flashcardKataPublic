//
//  ReadSettingsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View to show read settings, including flashcard selection and display options.

import SwiftUI

struct ReadSettingsScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReadViewModel
    @State private var reviewSettings: ReviewSettings = ReviewSettings()
    @State private var isSaving: Bool = false
    @State private var showSelectDeckView: Bool = false

    let loadFlashcards: () async -> Void

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

    private func saveReviewSettings() {
        Task {
            isSaving = true
            defer { isSaving = false }
            viewModel.reviewSettings = reviewSettings
            await loadFlashcards()
            dismiss()
        }
    }
}

#if DEBUG
#Preview {
    ReadSettingsScreen(
        viewModel: ReadViewModel(databaseManager: MockDatabaseManager()),
        loadFlashcards: {}
    )
}
#endif
