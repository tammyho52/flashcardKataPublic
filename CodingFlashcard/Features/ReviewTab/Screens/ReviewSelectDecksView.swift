//
//  ReviewSelectDecksView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReviewSelectDecksView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ReviewViewModel
    @State private var selectedParentDeckIDs: Set<String> = []
    @State private var selectedSubdeckIDs: Set<String> = []
    @State private var isLoading = false
    @State private var errorToast: Toast?
    @State private var showSelectFlashcardsView: Bool = false
    @Binding var showSelectDecksView: Bool
    
    var combinedSelectedDeckIDs: Set<String> {
        selectedParentDeckIDs.union(selectedSubdeckIDs)
    }
    
    var body: some View {
        NavigationStack {
            SelectDecksView(
                selectedParentDeckIDs: $selectedParentDeckIDs,
                selectedSubdeckIDs: $selectedSubdeckIDs,
                isLoading: $isLoading,
                loadDecksWithSubdecks: loadDecksWithSubdecks,
                sectionTitle: "Review Decks"
            )
            .navigationTitle("Deck Selection")
            .toolbarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .applyOverlayProgressScreen(isViewDisabled: $isLoading)
            .navigationDestination(isPresented: $showSelectFlashcardsView) {
                ReviewSelectFlashcardsScreen(
                    vm: vm,
                    showSelectDecksView: $showSelectDecksView,
                    showSelectFlashcardsView: $showSelectFlashcardsView,
                    previousSelectedDeckIDs: combinedSelectedDeckIDs
                )
            }
            .addToast(toast: $errorToast)
            .toolbar {
                toolbarExitButton(isDisabled: isLoading) {
                    dismiss()
                }
                
                toolbarNextButton(isDisabled: isLoading) {
                    showSelectFlashcardsView = true
                }
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
    ReviewSelectDecksView(vm: ReviewViewModel(databaseManager: MockDatabaseManager()), showSelectDecksView: .constant(true))
}
#endif
