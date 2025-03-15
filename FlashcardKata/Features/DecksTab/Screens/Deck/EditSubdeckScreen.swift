//
//  EditSubdeckScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for editing existing subdeck names.

import SwiftUI

struct EditSubdeckScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DeckFormViewModel
    @State private var selectedSubdeckName: SubdeckName?
    @State private var newSubdeckNameString = ""
    @State private var isLoading: Bool = false
    @State private var selectedDeck: Deck?
    @Binding var selectedDeckID: String?

    var body: some View {
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
                selectedDeck = try await viewModel.fetchDeck(id: fetchID)

                // Sets display for existing subdeck name
                if let selectedDeck {
                    selectedSubdeckName = SubdeckName(id: selectedDeck.id, name: selectedDeck.name)
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func resetAndExit() {
        newSubdeckNameString = ""
        self.selectedSubdeckName = nil
        dismiss()
    }

    private func updateSubdeckName() async {
        guard let selectedDeck, selectedDeck.name == selectedSubdeckName?.name else { return }
        isLoading = true
        if let selectedDeckID {
            try? await viewModel.updateDeck(id: selectedDeckID, updates: [.name(newSubdeckNameString)])
        }
        isLoading = false
        dismiss()
    }
}

#if DEBUG
#Preview {
    EditSubdeckScreen(
        viewModel: DeckFormViewModel(databaseManager: MockDatabaseManager()),
        selectedDeckID: .constant(Deck.sampleDeck.id)
    )
}
#endif
