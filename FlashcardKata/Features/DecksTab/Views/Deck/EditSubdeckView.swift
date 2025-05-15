//
//  EditSubdeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for editing the name of an existing subdeck within a deck.

import SwiftUI

/// A view for editing the name of an existing subdeck.
struct EditSubdeckView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: DeckFormViewModel
    @State private var selectedSubdeckName: SubdeckName? // The selected subdeck name to be edited.
    @State private var newSubdeckNameString = "" // The new name for the subdeck.
    @MainActor @State private var isLoading: Bool = false
    @State private var selectedDeck: Deck?
    @Binding var selectedDeckID: String?
    
    // MARK: - Body
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

    // MARK: - Private Methods
    /// Clears input and dismisses the view.
    private func resetAndExit() {
        newSubdeckNameString = ""
        self.selectedSubdeckName = nil
        dismiss()
    }
    
    /// Updates the name of the selected subdeck, then dismisses the view.
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

// MARK: - Preview
#if DEBUG
#Preview {
    EditSubdeckView(
        viewModel: DeckFormViewModel(databaseManager: MockDatabaseManager()),
        selectedDeckID: .constant(Deck.sampleDeck.id)
    )
}
#endif
