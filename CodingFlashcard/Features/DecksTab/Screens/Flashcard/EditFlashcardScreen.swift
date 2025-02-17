//
//  EditFlashcardView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct EditFlashcardScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: FlashcardFormViewModel
    @State private var focusedField: FlashcardFormField?
    @State var updatedFlashcard: Flashcard = Flashcard(deckID: UUID().uuidString)
    @State var isSaveButtonDisabled: Bool = true
    @State private var isLoading: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State var errorToast: Toast?
    @Binding var selectedFlashcardID: String?
   
    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)
    
    var body: some View {
        NavigationStack {
            FlashcardFormView(
                flashcard: $updatedFlashcard,
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
            Task {
                if let selectedFlashcardID, let fetchedFlashcard = try await vm.fetchFlashcard(id: selectedFlashcardID) {
                    updatedFlashcard = fetchedFlashcard
                }
            }
        }
        .onChange(of: updatedFlashcard) {
            debouncer.debounceAndCheck {
                isSaveButtonDisabled = checkIsSaveButtonDisabled()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Helper Functions
    private func checkIsSaveButtonDisabled() -> Bool {
        return updatedFlashcard.frontText.isEmpty || updatedFlashcard.backText.isEmpty || isFlashcardUnchanged
    }
    
    private var isFlashcardUnchanged: Bool {
        return updatedFlashcard.frontText == vm.initialFlashcard.frontText &&
        updatedFlashcard.backText == vm.initialFlashcard.backText &&
        updatedFlashcard.difficultyLevel == vm.initialFlashcard.difficultyLevel &&
        updatedFlashcard.notes == vm.initialFlashcard.notes &&
        updatedFlashcard.hint == vm.initialFlashcard.hint
    }
    
    private func saveButtonAction() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            try await vm.updateFlashcard(flashcard: updatedFlashcard)
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
                
                try await vm.deleteFlashcard(id: updatedFlashcard.id)
                showDeleteAlert = false
                dismiss()
            }
        }
    }
}

#if DEBUG
#Preview {
    EditFlashcardScreen(vm: FlashcardFormViewModel(databaseManager: MockDatabaseManager()), selectedFlashcardID: .constant(nil))
}
#endif
