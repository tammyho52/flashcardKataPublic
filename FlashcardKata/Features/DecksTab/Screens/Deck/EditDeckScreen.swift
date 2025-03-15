//
//  EditNewDeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for editing existing deck with form validation and error handling.

import SwiftUI

struct EditDeckScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DeckFormViewModel
    @State private var updatedDeck: Deck = Deck()
    @State private var updatedSubdeckNames: [SubdeckName] = []
    @State private var isSaveButtonDisabled: Bool = true
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var errorToast: Toast?
    @Binding var selectedDeckID: String?

    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)

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
                            showSaveAlert = true
                            showAlert = true
                        },
                        isEditView: true
                    )
                    .padding(.vertical, 10)
                    .applyOverlayProgressScreen(isViewDisabled: $isLoading)
                    .onChange(of: showAlert) { _, newValue in
                        if newValue == false {
                            showSaveAlert = false
                            showDeleteAlert = false
                        }
                    }
                    .onChange(of: updatedDeck) {
                        debouncer.debounceAndCheck {
                            isSaveButtonDisabled = checkIsSaveButtonDisabled()
                        }
                    }
                    .onChange(of: updatedSubdeckNames) {
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
            .navigationTitle("Edit Deck")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await loadInitialData()
                }
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

    // MARK: - Helper Methods
    private func loadInitialData() async {
        do {
            if let selectedDeckID {
                try await viewModel.loadEditDeckScreenData(selectedDeckID: selectedDeckID)
            }
            updatedDeck = viewModel.initialDeck
            updatedSubdeckNames = viewModel.initialSubdecks.map { subdeck in
                SubdeckName(id: subdeck.id, name: subdeck.name)
            }
        } catch {
            dismiss()
        }
    }

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

    private func setErrorToast(message: String) {
        errorToast = Toast(style: .warning, message: message)
    }

    // MARK: - Alert Components
    private var saveAlert: Alert {
        Alert(
            title: Text("Save Deck"),
            message: Text("Deleted subdecks and associated flashcards will be removed."),
            primaryButton: AlertHelper.cancelButton { showAlert = false },
            secondaryButton: saveButton()
        )
    }

    private func saveButton() -> Alert.Button {
        AlertHelper.saveButton {
            Task {
                do {
                    isLoading = true
                    defer { isLoading = false }

                    if updatedDeck.name != viewModel.initialDeck.name {
                        try await viewModel.updateDeck(id: updatedDeck.id, updates: [.name(updatedDeck.name)])
                    }
                    if updatedDeck.theme != viewModel.initialDeck.theme {
                        try await viewModel.updateDeck(id: updatedDeck.id, updates: [.theme(updatedDeck.theme)])
                    }

                    try await viewModel.saveUpdatedSubdecks(
                        newSubdeckNames: updatedSubdeckNames,
                        theme: updatedDeck.theme
                    )
                    showAlert = false
                    dismiss()
                } catch let error as AppError {
                    setErrorToast(message: error.message)
                } catch {
                    setErrorToast(message: AppError.unknownError.message)
                }
            }
        }
    }

    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete Deck"),
            message: Text("""
                Are you sure you want to delete this deck?
                All subdecks and flashcards will be removed. This action cannot be undone.
            """),
            primaryButton: AlertHelper.cancelButton { showAlert = false },
            secondaryButton: deleteButton()
        )
    }

    private func deleteButton() -> Alert.Button {
        AlertHelper.deleteButton {
            Task {
                isLoading = true
                defer { isLoading = false }

                try await viewModel.deleteDeckWithSubdecks()
                showAlert = false
                dismiss()
            }
        }
    }
}

#if DEBUG
#Preview {
    EditDeckScreen(
        viewModel: DeckFormViewModel(databaseManager: MockDatabaseManager()),
        selectedDeckID: .constant(Deck.sampleDeck.id)
    )
}
#endif
