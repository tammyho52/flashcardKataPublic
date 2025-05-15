//
//  AddNewDeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View responsible for presenting a form to create a new deck with form validation and error handling.

import SwiftUI

/// A view that allows users to create a new deck with input validation.
struct AddDeckScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DeckFormViewModel
    @State private var deck: Deck = Deck() // Deck object to be created
    @State private var subdeckNames: [SubdeckName] = [] // List of subdeck names
    @State private var isSaveButtonDisabled: Bool = true
    @State private var isSaving: Bool = false
    @MainActor @State private var errorToast: Toast?
    
    /// Debounces text field input changes to reduce unnecessary validations.
    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                DeckFormView(
                    deck: $deck,
                    subdeckNames: $subdeckNames,
                    isSaveButtonDisabled: $isSaveButtonDisabled,
                    saveButtonTitle: "Create Deck",
                    saveButtonAction: {
                        dismissKeyboard()
                        saveButtonAction()
                    },
                    isEditView: false
                )
                .padding(.top, 10)
                .applyOverlayProgressScreen(isViewDisabled: $isSaving)
                .onChange(of: deck.name) {
                    // Debounced validation to avoid frequent checks
                    debouncer.debounceAndCheck {
                        isSaveButtonDisabled = checkIsSaveButtonDisabled()
                    }
                }
            }
            .accessibilityIdentifier("addDeckScreen")
            .addToast(toast: $errorToast)
            .navigationTitle("New Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarBackButton(isDisabled: isSaving) { dismiss() }
            }
        }
    }

    // MARK: - Private Methods
    /// Checks if the save button should be disabled based on the deck name.
    private func checkIsSaveButtonDisabled() -> Bool {
        return deck.name.isEmpty
    }
    
    /// Attempts to save the deck and associated subdecks.
    private func saveButtonAction() {
        isSaving = true
        Task {
            defer {
                isSaving = false
                dismiss()
            }
            do {
                try await viewModel.saveDeck(deck: deck, subdeckNames: subdeckNames)
            } catch {
                updateErrorToast(error, errorToast: $errorToast)
                reportError(error)
                await sleepTaskForToast()
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        AddDeckScreen(
            viewModel: DeckFormViewModel(databaseManager: MockDatabaseManager())
        )
    }
}
#endif
