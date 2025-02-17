//
//  AddNewDeckView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct AddDeckScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: DeckFormViewModel
    @State var deck: Deck = Deck()
    @State var subdeckNames: [SubdeckName] = []
    @State var isSaveButtonDisabled: Bool = true
    @State var isSaving: Bool = false
    @State var errorToast: Toast?
    
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
    
    private func checkIsSaveButtonDisabled() -> Bool {
        return deck.name.isEmpty
    }
    
    private func saveButtonAction() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await vm.saveDeck(deck: deck, subdeckNames: subdeckNames)
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
        AddDeckScreen(vm: DeckFormViewModel(databaseManager: MockDatabaseManager()))
    }
}
#endif
