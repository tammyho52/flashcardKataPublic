//
//  EditFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for editing an existing flashcard.

import SwiftUI

/// This view allows users to edit an existing flashcard, with form validation and save functionality.
struct EditFlashcardScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashcardFormViewModel
    @State private var selectedFlashcard: Flashcard = Flashcard(deckID: UUID().uuidString) // Current flashcard being edited
    @State private var isSaveButtonDisabled: Bool = true
    @MainActor @State private var isLoading: Bool = false
    @MainActor @State private var showDeleteAlert: Bool = false
    @MainActor @State private var errorToast: Toast?
    @Binding var selectedFlashcardID: String?
    
    /// Debounces text field input changes to reduce unnecessary validations.
    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            FlashcardFormView(
                flashcard: $selectedFlashcard,
                showDeleteFlashcardButton: true,
                deleteFlashcardAction: { showDeleteAlert = true }
            )
            .accessibilityIdentifier("editFlashcardScreen")
            .applyOverlayProgressScreen(isViewDisabled: $isLoading)
            .navigationTitle("Edit Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .addToast(toast: $errorToast)
            .alert(isPresented: $showDeleteAlert) { deleteAlert }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        dismissKeyboard()
                        saveButtonAction()
                    }
                    .disabled(isSaveButtonDisabled)
                }
                toolbarBackButton { dismiss() }
            }
        }
        .onAppear {
            loadSelectedFlashcard()
        }
        .onChange(of: selectedFlashcard) {
            debouncer.debounceAndCheck {
                isSaveButtonDisabled = checkIsSaveButtonDisabled()
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Helper Functions
    /// Loads the selected flashcard from the database.
    private func loadSelectedFlashcard() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                if let selectedFlashcardID,
                    let fetchedFlashcard = try await viewModel.fetchFlashcard(id: selectedFlashcardID) {
                    selectedFlashcard = fetchedFlashcard
                }
            } catch {
                reportError(error)
                dismiss()
            }
        }
    }
    
    /// Checks if the save button should be disabled based on the current flashcard state.
    private func checkIsSaveButtonDisabled() -> Bool {
        return selectedFlashcard.frontText.isEmpty || selectedFlashcard.backText.isEmpty || isFlashcardUnchanged
    }
    
    /// Verifies if the flashcard has been modified before saving.
    private var isFlashcardUnchanged: Bool {
        return selectedFlashcard.frontText == viewModel.initialFlashcard.frontText &&
        selectedFlashcard.backText == viewModel.initialFlashcard.backText &&
        selectedFlashcard.difficultyLevel == viewModel.initialFlashcard.difficultyLevel &&
        selectedFlashcard.notes == viewModel.initialFlashcard.notes &&
        selectedFlashcard.hint == viewModel.initialFlashcard.hint
    }
    
    /// Updates the flashcard in the database and dismisses the view.
    private func saveButtonAction() {
        isLoading = true
        Task {
            defer {
                isLoading = false
                dismiss()
            }
            do {
                try await viewModel.updateFlashcard(flashcard: selectedFlashcard)
            } catch {
                updateErrorToast(error, errorToast: $errorToast)
                reportError(error)
                await sleepTaskForToast()
            }
        }
    }

    // MARK: - Alert
    /// The alert is presented when the user attempts to delete a flashcard.
    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete Flashcard"),
            message: Text("Are you sure you want to delete this flashcard? This action cannot be undone."),
            primaryButton: AlertHelper.cancelButton { showDeleteAlert = false },
            secondaryButton: deleteButton()
        )
    }

    private func deleteButton() -> Alert.Button {
        AlertHelper.deleteButton {
            isLoading = true
            Task {
                defer {
                    showDeleteAlert = false
                    isLoading = false
                    dismiss()
                }
                do {
                    try await viewModel.deleteFlashcard(id: selectedFlashcard.id)
                } catch {
                    updateErrorToast(error, errorToast: $errorToast)
                    reportError(error)
                    await sleepTaskForToast()
                }
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    EditFlashcardScreen(
        viewModel: FlashcardFormViewModel(databaseManager: MockDatabaseManager()),
        selectedFlashcardID: .constant(nil)
    )
}
#endif
