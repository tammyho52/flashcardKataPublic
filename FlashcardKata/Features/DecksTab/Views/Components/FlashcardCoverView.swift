//
//  FlashcardOverviewView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View to display flashcard information within a flashcard list.

import SwiftUI

/// A view that displays a flashcard's information within a list, including functionality for managing the flashcard.
struct FlashcardCoverView: View {
    // MARK: - Properties
    @Binding var showDeleteAlert: Bool // Controls the visibility of the delete confirmation alert.
    @Binding var showModifyFlashardButtons: Bool // Toggles the visibility of the modify flashcard buttons.
    @Binding var flashcard: Flashcard // The flashcard data to be displayed.

    let theme: Theme // The theme used for styling the flashcard view.
    let navigateToFlashcardAction: (String) -> Void
    let deleteFlashcardAction: (String) -> Void
    let modifyFlashcardAction: (String) -> Void

    // MARK: - Body
    var body: some View {
        Button {
            navigateToFlashcardAction(flashcard.id)
        } label: {
            VStack(alignment: .leading, spacing: 2.5) {
                HStack(alignment: .top) {
                    difficultyLabel
                        .padding(.bottom, 10)
                    Spacer()
                    modifyDeckButtons
                        .frame(width: 100, alignment: .trailing)
                }
                mainTextView // Displays the main text (front side) of the flashcard.
                bodyTextView // Displays the body text (back side) of the flashcard.
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(10)
            .background(
                LinearGradient(colors: [theme.secondaryColor.opacity(0.7), .white], startPoint: .top, endPoint: .bottom)
            )
            .background(.white)
            .clipDefaultShape()
            .applyCoverShadow()
        }
        .buttonStyle(.plain)
        .alert(isPresented: $showDeleteAlert) {
            deleteAlert // Displays a confirmation alert for deleting the flashcard.
        }
    }

    // MARK: - Text Views
    private var difficultyLabel: some View {
        BadgeLabel(
            text: flashcard.difficultyLevel.description,
            backgroundColor: flashcard.difficultyLevel.labelColor
        )
    }

    private var mainTextView: some View {
        Text(flashcard.frontText)
            .font(.customCallout)
            .fontWeight(.semibold)
            .padding(.leading, 5)
            .lineLimit(2, reservesSpace: true)
    }

    private var bodyTextView: some View {
        Text(flashcard.backText)
            .padding(.leading, 5)
            .font(.customCallout)
            .lineLimit(4, reservesSpace: true)
    }

    // MARK: - Button Views
    private var modifyDeckButtons: some View {
        HStack(spacing: 10) {
            if showModifyFlashardButtons {
                editFlashcardButton
                    .accessibilityIdentifier("editFlashcardButton_\(flashcard.id)")
                removeFlashcardButton
                    .accessibilityIdentifier("deleteFlashcardButton_\(flashcard.id)")
            }
        }
    }

    private var editFlashcardButton: some View {
        ModifyActionButton(
            showModifyButtons: $showModifyFlashardButtons,
            action: {
                modifyFlashcardAction(flashcard.id)
            },
            symbolName: "pencil.line"
        )
    }

    private var removeFlashcardButton: some View {
        ModifyActionButton(
            showModifyButtons: $showModifyFlashardButtons,
            action: {
                showDeleteAlert = true
            },
            symbolName: "trash"
        )
    }

    // MARK: - Alert Components
    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete Flashcard"),
            message: Text("Are you sure you want to delete this flashcard? This action cannot be undone."),
            primaryButton: AlertHelper.cancelButton { showDeleteAlert = false },
            secondaryButton: deleteAlertButton()
        )
    }

    private func deleteAlertButton() -> Alert.Button {
        AlertHelper.deleteButton {
            deleteFlashcardAction(flashcard.id)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    FlashcardCoverView(
        showDeleteAlert: .constant(false),
        showModifyFlashardButtons: .constant(true),
        flashcard: .constant(Flashcard.sampleFlashcard),
        theme: .blue,
        navigateToFlashcardAction: { _ in },
        deleteFlashcardAction: { _ in },
        modifyFlashcardAction: { _ in }
    )
}
#endif
