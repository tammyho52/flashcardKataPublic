
//  NewFlashcardView.swift
//  CodingFlashcard

//  Created by Tammy Ho


import SwiftUI

struct AddFlashcardScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: FlashcardFormViewModel
    @State private var focusedField: FlashcardFormField?
    @State var flashcard: Flashcard
    @State private var optionalSectionExpanded: Bool = true
    @State private var isSaving = false
    @State private var isSaveButtonDisabled: Bool = true
    @State var errorToast: Toast?
    var selectedDeckID: String?
    
    private let debouncer = DebouncerTextValidationService(timeInterval: DesignConstants.debouncerTimeInterval)
   
    var body: some View {
        NavigationStack {
            FlashcardFormView(flashcard: $flashcard, focusedField: $focusedField)
                .applyOverlayProgressScreen(isViewDisabled: $isSaving)
                .onChange(of: flashcard) {
                    debouncer.debounceAndCheck {
                        isSaveButtonDisabled = checkIsSaveButtonDisabled()
                    }
                }
                .navigationTitle("New Flashcard")
                .navigationBarTitleDisplayMode(.inline)
                .addToast(toast: $errorToast)
                .navigationBarBackButtonHidden()
                .onChange(of: flashcard) {
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
    
    private func saveButtonAction() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            isSaveButtonDisabled = true
            try await vm.createFlashcard(flashcard: flashcard)
            dismiss()
        } catch let error as AppError {
            setErrorToast(message: error.message)
        } catch {
            setErrorToast(message: AppError.unknownError.message)
        }
    }
    
    private func checkIsSaveButtonDisabled() -> Bool {
        return flashcard.frontText.isEmpty || flashcard.backText.isEmpty
    }
    
    private func setErrorToast(message: String) {
        errorToast = Toast(style: .warning, message: message)
    }
}

extension AddFlashcardScreen {
    init(vm: FlashcardFormViewModel, selectedDeckID: String?) {
        _vm = ObservedObject(wrappedValue: vm)
        _flashcard = State(initialValue: Flashcard(deckID: selectedDeckID ?? UUID().uuidString))
        self.selectedDeckID = selectedDeckID
    }
}

#if DEBUG
#Preview {
    AddFlashcardScreen(vm: FlashcardFormViewModel(databaseManager: MockDatabaseManager()), flashcard: Flashcard(deckID: Deck.sampleDeck.id), selectedDeckID: Deck.sampleDeck.id)
}
#endif
