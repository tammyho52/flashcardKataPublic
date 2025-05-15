//
//  FlashcardReviewSettingsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Settings view for selecting flashcards to review and configure information shown.

import SwiftUI

struct ReviewSettingsSections: View {
    @Binding var showSelectDeckView: Bool
    @Binding var reviewSettings: ReviewSettings

    let clearSelectedFlashcardIDs: () -> Void

    var body: some View {
        Section {
            FlashcardModePicker(
                selectedFlashcardMode: $reviewSettings.selectedFlashcardMode,
                showCustomSelectionView: $showSelectDeckView,
                clearSelectedFlashcardIDs: clearSelectedFlashcardIDs
            )
        } header: {
            Text("Select Flashcards")
                .applyListSectionStyle()
        }
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)

        Section {
            ReviewSettingsSection(reviewSettings: $reviewSettings)
        } header: {
            Text("Settings")
                .applyListSectionStyle()
        }
        .listRowSeparator(.hidden)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    List {
        ReviewSettingsSections(
            showSelectDeckView: .constant(false),
            reviewSettings: .constant(ReviewSettings()),
            clearSelectedFlashcardIDs: {}
        )
    }
    .listStyle(.inset)
}
#endif
