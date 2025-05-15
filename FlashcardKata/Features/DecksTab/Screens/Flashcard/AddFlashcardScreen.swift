//
//  NewFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for adding a new flashcard to the selected deck.

import SwiftUI

/// A view that provides a form to add a new flashcard to the selected deck.
struct AddFlashcardScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashcardFormViewModel
    @State private var newFlashcard: Flashcard // The new flashcard being created
    @State private var optionalSectionExpanded: Bool = true
    @MainActor @State private var isSaving = false
    @State private var isSaveButtonDisabled: Bool = true
    @MainActor @State private var errorToast: Toast?
    @Binding var selectedDeckID: String? // ID of the selected deck, passed to new flashcards to associate them with the correct deck
    
    /// Debounces text field input changes to reduce unnecessary validations.
    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)

    // MARK: - Body
    var body: some View {
        NavigationStack {
            FlashcardFormView(
                flashcard: $newFlashcard,
                showDeleteFlashcardButton: false,
                deleteFlashcardAction: {} // No delete action needed here
            )
            .accessibilityIdentifier("addFlashcardScreen")
            .applyOverlayProgressScreen(isViewDisabled: $isSaving)
            .navigationTitle("New Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .addToast(toast: $errorToast)
            .navigationBarBackButtonHidden()
            .onChange(of: newFlashcard) {
                // Update the save button state when the flashcard changes
                debouncer.debounceAndCheck {
                    isSaveButtonDisabled = checkIsSaveButtonDisabled()
                }
            }
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
    }

    // MARK: - Private Methods
    /// Save the new flashcard and dismiss the view.
    private func saveButtonAction() {
        isSaving = true
        Task {
            defer {
                isSaving = false
                dismiss()
            }
            do {
                isSaveButtonDisabled = true
                try await viewModel.createFlashcard(flashcard: newFlashcard)
            } catch {
                updateErrorToast(error, errorToast: $errorToast)
                reportError(error)
                await sleepTaskForToast()
            }
        }
    }
    
    /// Check if the save button should be disabled based on the flashcard's text fields.
    private func checkIsSaveButtonDisabled() -> Bool {
        return newFlashcard.frontText.isEmpty || newFlashcard.backText.isEmpty
    }
}

extension AddFlashcardScreen {
    // MARK: - Initializer
    init(viewModel: FlashcardFormViewModel, selectedDeckID: Binding<String?>) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self._selectedDeckID = selectedDeckID
        _newFlashcard = State(initialValue: Flashcard(deckID: selectedDeckID.wrappedValue ?? UUID().uuidString))
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    AddFlashcardScreen(
        viewModel: FlashcardFormViewModel(databaseManager: MockDatabaseManager()),
        selectedDeckID: .constant(Deck.sampleDeck.id)
    )
}
#endif
