//
//  ReadSelectDecksView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReadSelectDecksScreen: View {
    @ObservedObject var vm: ReadViewModel
    @State private var selectedParentDeckIDs: Set<String> = []
    @State private var selectedSubdeckIDs: Set<String> = []
    @State private var isLoading = false
    @State private var errorToast: Toast?
    @State private var showSelectFlashcardsView: Bool = false
    @Binding var selectedFlashcardIDs: Set<String>
    @Binding var showSelectDeckView: Bool
    
    var combinedSelectedDeckIDs: Set<String> {
        selectedParentDeckIDs.union(selectedSubdeckIDs)
    }
    
    var body: some View {
        SelectDecksView(
            selectedParentDeckIDs: $selectedParentDeckIDs,
            selectedSubdeckIDs: $selectedSubdeckIDs,
            isLoading: $isLoading,
            loadDecksWithSubdecks: loadDecksWithSubdecks,
            sectionTitle: "Read Decks"
        )
        .navigationTitle("Deck Selection")
        .toolbarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .navigationDestination(isPresented: $showSelectFlashcardsView) {
            ReadSelectFlashcardsScreen(
                vm: vm,
                selectedFlashcardIDs: $selectedFlashcardIDs,
                showSelectDecksView: $showSelectDeckView,
                showSelectFlashcardsView: $showSelectFlashcardsView,
                previousSelectedDeckIDs: combinedSelectedDeckIDs
            )
        }
        .addToast(toast: $errorToast)
        .toolbar {
            toolbarBackButton(isDisabled: isLoading) {
                showSelectDeckView = false
            }
            
            toolbarNextButton(isDisabled: isLoading) {
                showSelectFlashcardsView = true
            }
        }
    }
    
    private func loadDecksWithSubdecks() async -> [(Deck, [Deck])] {
        do {
            return try await vm.loadParentDecksWithSubDecks()
        } catch {
            errorToast = Toast(style: .warning, message: "Unable to select decks at this time. Please try again later.")
        }
        return []
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ReadSelectDecksScreen(vm: ReadViewModel(databaseManager: MockDatabaseManager()), selectedFlashcardIDs: .constant(Set(Flashcard.sampleFlashcardArray.map { $0.id })), showSelectDeckView: .constant(true))
    }
}
#endif
