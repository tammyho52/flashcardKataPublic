//
//  FlashcardOverviewView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View to display flashcard information within a flashcard list.

import SwiftUI

struct FlashcardCoverView: View {
    @State private var showDeleteAlert: Bool = false
    @Binding var showModifyFlashardButtons: Bool
    @Binding var flashcard: Flashcard

    let theme: Theme
    let navigateToFlashcardAction: (String) -> Void
    let deleteFlashcardAction: (String) async throws -> Void
    let modifyFlashcardAction: (String) -> Void

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
                mainTextView
                bodyTextView
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
            deleteAlert
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
                removeFlashcardButton
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
            Task {
                do {
                    try await deleteFlashcardAction(flashcard.id)
                    showDeleteAlert = false
                } catch {
                    showDeleteAlert = false
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    FlashcardCoverView(
        showModifyFlashardButtons: .constant(true),
        flashcard: .constant(Flashcard.sampleFlashcard),
        theme: .blue,
        navigateToFlashcardAction: { _ in },
        deleteFlashcardAction: { _ in },
        modifyFlashcardAction: { _ in }
    )
}
#endif
