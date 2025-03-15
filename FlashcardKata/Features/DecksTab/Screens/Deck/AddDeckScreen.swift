//
//  AddNewDeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for creating a new deck with form validation and error handling.

import SwiftUI

struct AddDeckScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DeckFormViewModel
    @State private var deck: Deck = Deck()
    @State private var subdeckNames: [SubdeckName] = []
    @State private var isSaveButtonDisabled: Bool = true
    @State private var isSaving: Bool = false
    @State private var errorToast: Toast?

    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)

    var body: some View {
        NavigationStack {
            ScrollView {
                DeckFormView(
                    deck: $deck,
                    subdeckNames: $subdeckNames,
                    isSaveButtonDisabled: $isSaveButtonDisabled,
                    saveButtonTitle: "Create Deck",
                    saveButtonAction: {
                        Task {
                            await saveButtonAction()
                            dismiss()
                        }
                    },
                    isEditView: false
                )
                .padding(.top, 10)
                .applyOverlayProgressScreen(isViewDisabled: $isSaving)
                .onChange(of: deck.name) {
                    // Form validation
                    debouncer.debounceAndCheck {
                        isSaveButtonDisabled = checkIsSaveButtonDisabled()
                    }
                }
            }
            .addToast(toast: $errorToast)
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarBackButton(isDisabled: isSaving) { dismiss() }
            }
        }
    }

    // MARK: - Helper Methods
    private func checkIsSaveButtonDisabled() -> Bool {
        return deck.name.isEmpty
    }

    private func saveButtonAction() async {
        isSaving = true
        defer { isSaving = false }

        do {
            try await viewModel.saveDeck(deck: deck, subdeckNames: subdeckNames)
            dismiss()
        } catch let error as AppError {
            setErrorToast(message: error.message)
        } catch {
            setErrorToast(message: AppError.unknownError.message)
        }
    }

    private func setErrorToast(message: String) {
        errorToast = Toast(style: .warning, message: message)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AddDeckScreen(viewModel: DeckFormViewModel(databaseManager: MockDatabaseManager()))
    }
}
#endif
