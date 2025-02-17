//
//  DeckDisclosureGroupView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct DeckDisclosureGroupView: View {
    
    @State var showDeleteAlert: Bool = false
    @State var selectedDeckID: String? = nil
    @State var isExpanded: Bool = false
    
    @Binding var deck: Deck
    @Binding var showModifyDeckButtons: Bool
    @Binding var disableModifyDeckButtons: Bool
    @Binding var subdecks: [Deck]
    var deleteDeckAction: (String) async throws -> Void
    var modifyDeckAction: (String) -> Void
    var navigateAction: (String) -> Void

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            LazyVStack(spacing: 20) {
                ForEach(subdecks) { subdeck in
                    deckButton(for: subdeck)
                }
            }
        } label: {
            deckButton(for: deck, subdeckButtonAction: {
                if !subdecks.isEmpty {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            })
            .id(deck.id)
        }
        .tint(subdecks.isEmpty ? .clear : deck.theme.primaryColor)
        .alert(isPresented: $showDeleteAlert) {
            deleteAlert
        }
        .onChange(of: subdecks) {
            if subdecks.count == 0 {
                isExpanded = false
            }
        }
    }
    
    private func deckButton(for deck: Deck, subdeckButtonAction: @escaping () -> Void = {}) -> some View {
        DeckCoverButton(
            showModifyDeckButtons: $showModifyDeckButtons,
            disableModifyDeckButtons: $disableModifyDeckButtons,
            deck: deck,
            navigateAction: {
                navigateAction(deck.id)
            }, removeDeckAction: {
                removeDeckAction(id: deck.id)
            }, editDeckAction: {
                modifyDeckAction(id: deck.id)
            }, subdeckButtonAction: subdeckButtonAction
        )
        .buttonStyle(.plain)
        .listRowBackground(Color.clear)
    }
    
    func removeDeckAction(id: String) {
        selectedDeckID = id
        showDeleteAlert = true
    }
    
    func modifyDeckAction(id: String) {
        selectedDeckID = deck.id
        modifyDeckAction(deck.id)
    }
    
    // MARK: - Alert Components
    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete Deck"),
            message: Text("Are you sure you want to delete \(deck.name) \(deck.subdeckCount > 0 ? "and all associated subdecks" : "")? This action cannot be undone."),
            primaryButton: AlertHelper.cancelButton { showDeleteAlert = false },
            secondaryButton: deleteButton()
        )
    }
    
    private func deleteButton() -> Alert.Button {
        AlertHelper.deleteButton {
            if let deckID = selectedDeckID {
                Task {
                    try await deleteDeckAction(deckID)
                    showDeleteAlert = false
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        VStack {
            DeckDisclosureGroupView(deck: .constant(Deck.sampleDeck), showModifyDeckButtons: .constant(true), disableModifyDeckButtons: .constant(false), subdecks: .constant(Deck.sampleSubdeckArray), deleteDeckAction: {_ in }, modifyDeckAction: {_ in }, navigateAction: {_ in })
        }
    }
}

#Preview {
    ScrollView {
        DeckDisclosureGroupView(deck: .constant(Deck.sampleDeck), showModifyDeckButtons: .constant(false), disableModifyDeckButtons: .constant(false), subdecks: .constant(Deck.sampleSubdeckArray), deleteDeckAction: {_  in }, modifyDeckAction: {_ in }, navigateAction: {_ in })
    }
}
#endif

