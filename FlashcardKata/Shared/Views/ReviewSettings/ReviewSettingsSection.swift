//
//  ReviewSettingsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays settings for the user to customize flashcard information for review.

import SwiftUI

struct ReviewSettingsSection: View {
    @Binding var reviewSettings: ReviewSettings
    var body: some View {
        Group {
            labeledDisplayOrderPicker
            LabeledToggleRow(
                isOn: $reviewSettings.showHint,
                labelText: "Show Hint",
                symbol: ContentConstants.Symbols.hint
            )
            LabeledToggleRow(
                isOn: $reviewSettings.showDifficultyLevel,
                labelText: "Show Difficulty Level",
                symbol: ContentConstants.Symbols.difficultyLevel
            )
            LabeledToggleRow(
                isOn: $reviewSettings.showFlashcardDeckName,
                labelText: "Include Deck Name",
                symbol: ContentConstants.Symbols.deck
            )
        }
        .listRowSeparator(.hidden)
    }

    var labeledDisplayOrderPicker: some View {
        HStack {
            Label {
                Text("Display Order")
            } icon: {
                Image(systemName: "rectangle.3.group")
                    .foregroundStyle(DesignConstants.Colors.iconSecondary)
            }
            Spacer()
            Picker("Card Sort", selection: $reviewSettings.displayCardSort) {
                ForEach(CardSort.allCases) { cardSort in
                    Text(cardSort.rawValueCapitalized)
                }
            }
            .labelsHidden()
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    List {
        ReviewSettingsSection(reviewSettings: .constant(ReviewSettings()))
    }
}
#endif
