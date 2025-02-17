//
//  EditSubdeckScreen.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct EditSubdeckScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: DeckFormViewModel
    @State private var selectedSubdeckName: SubdeckName?
    @State private var newSubdeckNameString = ""
    @State private var isLoading: Bool = false
    @State private var selectedDeck: Deck?
    @Binding var selectedDeckID: String?
    
    var body: some View {
        NavigationStack {
            EditSubdeckNameView(
                selectedSubdeckName: $selectedSubdeckName,
                newSubdeckNameString: $newSubdeckNameString,
                resetAndExit: resetAndExit,
                updateSubdeckName: updateSubdeckName
            )
            .applyOverlayProgressScreen(isViewDisabled: $isLoading)
            .onAppear {
                Task {
                    guard let fetchID = selectedDeckID else { return }
                    selectedDeck = try await vm.fetchDeck(id: fetchID)
                    
                    if let selectedDeck {
                        selectedSubdeckName = SubdeckName(id: selectedDeck.id, name: selectedDeck.name)
                    }
                }
            }
        }
    }
    
    private func resetAndExit() {
        newSubdeckNameString = ""
        self.selectedSubdeckName = nil
        dismiss()
    }
    
    private func updateSubdeckName() async {
        guard let selectedDeck, selectedDeck.name == selectedSubdeckName?.name else { return }
        isLoading = true
        if let selectedDeckID {
            try? await vm.updateDeck(id: selectedDeckID, updates: [.name(newSubdeckNameString)])
        }
        isLoading = false
        dismiss()
    }
}

#if DEBUG
#Preview {
    EditSubdeckScreen(vm: DeckFormViewModel(databaseManager: MockDatabaseManager()), selectedDeckID: .constant(Deck.sampleDeck.id))
}
#endif
