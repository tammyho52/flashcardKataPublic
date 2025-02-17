//
//  ReadSettingsView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReadSettingsScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ReadViewModel
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
                    clearSelectedFlashcardIDs: vm.clearSelectedFlashcardIDs
                )
            }
            .listStyle(.inset)
            .applyOverlayProgressScreen(isViewDisabled: $isSaving)
            .navigationTitle("Read Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $showSelectDeckView) {
                ReadSelectDecksScreen(
                    vm: vm,
                    selectedFlashcardIDs: $reviewSettings.selectedFlashcardIDs,
                    showSelectDeckView: $showSelectDeckView
                )
            }
            .onChange(of: showSelectDeckView) { _, newValue in
                if newValue {
                    vm.reviewSettings = reviewSettings
                }
            }
            .onAppear {
                reviewSettings = vm.reviewSettings
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
            vm.reviewSettings = reviewSettings
            await loadFlashcards()
            dismiss()
        }
    }
}

#if DEBUG
#Preview {
    ReadSettingsScreen(vm: ReadViewModel(databaseManager: MockDatabaseManager()), loadFlashcards: {})
}
#endif
