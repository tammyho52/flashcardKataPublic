//
//  NewFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for adding a new flashcard to selected deck.

import SwiftUI

struct AddFlashcardScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashcardFormViewModel
    @State private var focusedField: FlashcardFormField?
    @State private var newFlashcard: Flashcard
    @State private var optionalSectionExpanded: Bool = true
    @State private var isSaving = false
    @State private var isSaveButtonDisabled: Bool = true
    @State private var errorToast: Toast?
    var selectedDeckID: String?

    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)

    var body: some View {
        NavigationStack {
            FlashcardFormView(flashcard: $newFlashcard, focusedField: $focusedField)
                .applyOverlayProgressScreen(isViewDisabled: $isSaving)
                .onChange(of: newFlashcard) {
                    debouncer.debounceAndCheck {
                        isSaveButtonDisabled = checkIsSaveButtonDisabled()
                    }
                }
                .navigationTitle("New Flashcard")
                .navigationBarTitleDisplayMode(.inline)
                .addToast(toast: $errorToast)
                .navigationBarBackButtonHidden()
                .onChange(of: newFlashcard) {
                    debouncer.debounceAndCheck {
                        isSaveButtonDisabled = checkIsSaveButtonDisabled()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task {
                                focusedField = nil
                                await saveButtonAction()
                                dismiss()
                            }
                        }
                        .disabled(isSaveButtonDisabled)
                    }
                    toolbarBackButton { dismiss() }
                }
        }
    }

    // MARK: - Helper Methods
    private func saveButtonAction() async {
        isSaving = true
        defer { isSaving = false }

        do {
            isSaveButtonDisabled = true
            try await viewModel.createFlashcard(flashcard: newFlashcard)
            dismiss()
        } catch let error as AppError {
            setErrorToast(message: error.message)
        } catch {
            setErrorToast(message: AppError.unknownError.message)
        }
    }

    private func checkIsSaveButtonDisabled() -> Bool {
        return newFlashcard.frontText.isEmpty || newFlashcard.backText.isEmpty
    }

    private func setErrorToast(message: String) {
        errorToast = Toast(style: .warning, message: message)
    }
}

extension AddFlashcardScreen {
    init(viewModel: FlashcardFormViewModel, selectedDeckID: String?) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _newFlashcard = State(initialValue: Flashcard(deckID: selectedDeckID ?? UUID().uuidString))
        self.selectedDeckID = selectedDeckID
    }
}

#if DEBUG
#Preview {
    AddFlashcardScreen(
        viewModel: FlashcardFormViewModel(databaseManager: MockDatabaseManager()),
        selectedDeckID: Deck.sampleDeck.id
    )
}
#endif
