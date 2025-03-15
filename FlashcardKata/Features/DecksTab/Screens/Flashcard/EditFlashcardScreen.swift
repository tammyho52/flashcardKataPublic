//
//  EditFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for editing an existing flashcard.

import SwiftUI

struct EditFlashcardScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashcardFormViewModel
    @State private var focusedField: FlashcardFormField?
    @State private var selectedFlashcard: Flashcard = Flashcard(deckID: UUID().uuidString)
    @State private var isSaveButtonDisabled: Bool = true
    @State private var isLoading: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorToast: Toast?
    @Binding var selectedFlashcardID: String?

    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)

    var body: some View {
        NavigationStack {
            FlashcardFormView(
                flashcard: $selectedFlashcard,
                focusedField: $focusedField,
                showDeleteFlashcardButton: true,
                deleteFlashcardAction: { showDeleteAlert = true }
            )
            .applyOverlayProgressScreen(isViewDisabled: $isLoading)
            .navigationTitle("Edit Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .addToast(toast: $errorToast)
            .alert(isPresented: $showDeleteAlert) { deleteAlert }
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
        .onAppear {
            // Loads current selected flashcard
            Task {
                if let selectedFlashcardID,
                    let fetchedFlashcard = try await viewModel.fetchFlashcard(id: selectedFlashcardID) {
                    selectedFlashcard = fetchedFlashcard
                }
            }
        }
        .onChange(of: selectedFlashcard) {
            debouncer.debounceAndCheck {
                isSaveButtonDisabled = checkIsSaveButtonDisabled()
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Helper Functions
    private func checkIsSaveButtonDisabled() -> Bool {
        return selectedFlashcard.frontText.isEmpty || selectedFlashcard.backText.isEmpty || isFlashcardUnchanged
    }

    private var isFlashcardUnchanged: Bool {
        return selectedFlashcard.frontText == viewModel.initialFlashcard.frontText &&
        selectedFlashcard.backText == viewModel.initialFlashcard.backText &&
        selectedFlashcard.difficultyLevel == viewModel.initialFlashcard.difficultyLevel &&
        selectedFlashcard.notes == viewModel.initialFlashcard.notes &&
        selectedFlashcard.hint == viewModel.initialFlashcard.hint
    }

    private func saveButtonAction() async {
        do {
            isLoading = true
            defer { isLoading = false }

            try await viewModel.updateFlashcard(flashcard: selectedFlashcard)
        } catch let error as AppError {
            setErrorToast(message: error.message)
        } catch {
            setErrorToast(message: AppError.unknownError.message)
        }
    }

    private func setErrorToast(message: String) {
        errorToast = Toast(style: .warning, message: message)
    }

    // MARK: - Delete Alert
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
            Task {
                isLoading = true
                defer { isLoading = false }

                try await viewModel.deleteFlashcard(id: selectedFlashcard.id)
                showDeleteAlert = false
                dismiss()
            }
        }
    }
}

#if DEBUG
#Preview {
    EditFlashcardScreen(
        viewModel: FlashcardFormViewModel(databaseManager: MockDatabaseManager()),
        selectedFlashcardID: .constant(nil)
    )
}
#endif
