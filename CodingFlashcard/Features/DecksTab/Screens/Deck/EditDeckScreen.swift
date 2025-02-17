//
//  EditNewDeckView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct EditDeckScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: DeckFormViewModel
    @State var updatedDeck: Deck = Deck()
    @State var updatedSubdeckNames: [SubdeckName] = []
    @State var isSaveButtonDisabled: Bool = true
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var showSaveAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State var errorToast: Toast?
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
                    deleteDeckButton
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
    
    private var deleteDeckButton: some View {
        Button("Delete Deck", role: .destructive) {
            showDeleteAlert = true
            showAlert = true
        }
    }
    
    private func loadInitialData() async {
        do {
            if let selectedDeckID {
                try await vm.loadEditDeckScreenData(selectedDeckID: selectedDeckID)
            }
            updatedDeck = vm.initialDeck
            updatedSubdeckNames = vm.initialSubdecks.map { subdeck in
                SubdeckName(id: subdeck.id, name: subdeck.name)
            }
        } catch {
            dismiss()
        }
    }
    
    private func mapExistingSubdeckNames() {
        updatedSubdeckNames = vm.initialSubdecks.map { subdeck in
            SubdeckName(id: subdeck.id, name: subdeck.name)
        }
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
                    
                    if updatedDeck.name != vm.initialDeck.name {
                        try await vm.updateDeck(id: updatedDeck.id, updates: [.name(updatedDeck.name)])
                    }
                    if updatedDeck.theme != vm.initialDeck.theme {
                        try await vm.updateDeck(id: updatedDeck.id, updates: [.theme(updatedDeck.theme)])
                    }
                    
                    try await vm.saveUpdatedSubdecks(newSubdeckNames: updatedSubdeckNames, theme: updatedDeck.theme)
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
    
    // - Delete Alert
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
            Task {
                isLoading = true
                defer { isLoading = false }
                
                try await vm.deleteDeckWithSubdecks()
                showAlert = false
                dismiss()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func checkIsSaveButtonDisabled() -> Bool {
        return updatedDeck.name.isEmpty || (isDeckUnchanged && isSubdeckUnchanged)
    }
    
    private var isDeckUnchanged: Bool {
        return updatedDeck.name == vm.initialDeck.name && updatedDeck.theme == vm.initialDeck.theme
    }
    
    private var isSubdeckUnchanged: Bool {
        return updatedSubdeckNames.map { $0.name }.sorted() == vm.initialSubdecks.map { $0.name }.sorted()
    }
    
    private func setErrorToast(message: String) {
        errorToast = Toast(style: .warning, message: message)
    }
}

#if DEBUG
#Preview {
    EditDeckScreen(vm: DeckFormViewModel(databaseManager: MockDatabaseManager()), selectedDeckID: .constant(Deck.sampleDeck.id))
}
#endif
