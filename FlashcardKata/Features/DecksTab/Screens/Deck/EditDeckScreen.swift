//
//  EditDeckScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for editing an existing deck with form validation and error handling.

import SwiftUI

/// A view that allows users to edit an existing deck with input validation.
struct EditDeckScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DeckFormViewModel
    @State private var updatedDeck: Deck = Deck() // Editable deck object
    @State private var updatedSubdeckNames: [SubdeckName] = [] // Editable subdeck names
    @State private var isSaveButtonDisabled: Bool = true
    @MainActor @State private var isLoading: Bool = false
    @MainActor @State private var showAlert: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorToast: Toast?
    @Binding var selectedDeckID: String? // ID of the deck currently being edited
    
    /// Debounces text field input changes to reduce unnecessary validations.
    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    DeckFormView(
                        deck: $updatedDeck,
                        subdeckNames: $updatedSubdeckNames,
                        isSaveButtonDisabled: $isSaveButtonDisabled,
                        saveButtonTitle: "Save Deck",
                        saveButtonAction: {
                            dismissKeyboard()
                            showSaveAlert = true
                            showAlert = true
                        },
                        isEditView: true
                    )
                    .padding(.vertical, 10)
                    .applyOverlayProgressScreen(isViewDisabled: $isLoading)
                    .onChange(of: showAlert) { _, newValue in
                        // Reset alerts when the user dismisses the alert
                        if newValue == false {
                            showSaveAlert = false
                            showDeleteAlert = false
                        }
                    }
                    .onChange(of: updatedDeck) {
                        // Debounce the changes to deck for validation
                        debouncer.debounceAndCheck {
                            isSaveButtonDisabled = checkIsSaveButtonDisabled()
                        }
                    }
                    .onChange(of: updatedSubdeckNames) {
                        // Debounce the changes to subdeck names for validation
                        debouncer.debounceAndCheck {
                            isSaveButtonDisabled = checkIsSaveButtonDisabled()
                        }
                    }

                    Button("Delete Deck", role: .destructive) {
                        showDeleteAlert = true
                        showAlert = true
                    }
                    .padding(.top, 50)
                }
            }
            .accessibilityIdentifier("editDeckScreen")
            .navigationTitle("Edit Deck")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadInitialData()
            }
            .addToast(toast: $errorToast)
            .alert(isPresented: $showAlert) {
                if showSaveAlert {
                    return saveAlert
                } else if showDeleteAlert {
                    return deleteAlert
                } else {
                    return Alert(title: Text("No Action"))
                }
            }
            .toolbar {
                toolbarBackButton(isDisabled: isLoading) { dismiss() }
            }
        }
    }

    // MARK: - Private Methods
    /// Load initial data for the edit deck screen to match existing deck details.
    private func loadInitialData() {
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                if let selectedDeckID {
                    try await viewModel.loadEditDeckScreenData(selectedDeckID: selectedDeckID)
                }
                updatedDeck = viewModel.initialDeck
                updatedSubdeckNames = viewModel.initialSubdecks.map { subdeck in
                    SubdeckName(id: subdeck.id, name: subdeck.name)
                }
            } catch {
                reportError(error)
                dismiss()
            }
        }
    }
    
    /// Map the existing subdeck names to the form's `SubdeckName` data structure.
    private func mapExistingSubdeckNames() {
        updatedSubdeckNames = viewModel.initialSubdecks.map { subdeck in
            SubdeckName(id: subdeck.id, name: subdeck.name)
        }
    }
    
    private func checkIsSaveButtonDisabled() -> Bool {
        return updatedDeck.name.isEmpty || (isDeckUnchanged && isSubdeckUnchanged)
    }

    private var isDeckUnchanged: Bool {
        return updatedDeck.name == viewModel.initialDeck.name && updatedDeck.theme == viewModel.initialDeck.theme
    }

    private var isSubdeckUnchanged: Bool {
        return updatedSubdeckNames.map { $0.name }.sorted() == viewModel.initialSubdecks.map { $0.name }.sorted()
    }
    
    /// Update the deck name if it has changed.
    private func updateDeckName() async throws {
        if updatedDeck.name != viewModel.initialDeck.name {
            try await viewModel.updateDeck(id: updatedDeck.id, updates: [.name(updatedDeck.name)])
        }
    }
    
    /// Update the deck theme if it has changed.
    private func updateDeckTheme() async throws {
        if updatedDeck.theme != viewModel.initialDeck.theme {
            try await viewModel.updateDeck(id: updatedDeck.id, updates: [.theme(updatedDeck.theme)])
        }
    }

    // MARK: - Alert Components
    /// The alert is shown when the user attempts to save the deck.
    private var saveAlert: Alert {
        Alert(
            title: Text("Save Deck"),
            message: Text("Deleted subdecks and associated flashcards will be removed."),
            primaryButton: AlertHelper.cancelButton { showAlert = false },
            secondaryButton: saveButton()
        )
    }
    
    /// Button action for saving the deck.
    private func saveButton() -> Alert.Button {
        AlertHelper.saveButton {
            isLoading = true
            Task {
                defer {
                    isLoading = false
                    showAlert = false
                    dismiss()
                }
                do {
                    try await updateDeckName()
                    try await updateDeckTheme()
                    try await viewModel.saveUpdatedSubdecks(
                        newSubdeckNames: updatedSubdeckNames,
                        theme: updatedDeck.theme
                    )
                } catch {
                    updateErrorToast(error, errorToast: $errorToast)
                    reportError(error)
                    await sleepTaskForToast()
                }
            }
        }
    }

    /// The alert is shown when the user attempts to delete the deck.
    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete Deck"),
            message: Text("Are you sure you want to delete this deck? All subdecks and flashcards will be removed. This action cannot be undone."),
            primaryButton: AlertHelper.cancelButton { showAlert = false },
            secondaryButton: deleteButton()
        )
    }
    
    private func deleteButton() -> Alert.Button {
        AlertHelper.deleteButton {
            isLoading = true
            Task {
                defer { isLoading = false }
                try await viewModel.deleteDeckWithSubdecks()
                showAlert = false
                dismiss()
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    EditDeckScreen(
        viewModel: DeckFormViewModel(databaseManager: MockDatabaseManager()),
        selectedDeckID: .constant(Deck.sampleDeck.id)
    )
}
#endif
