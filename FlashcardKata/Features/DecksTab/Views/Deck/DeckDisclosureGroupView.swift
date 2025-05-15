//
//  DeckDisclosureGroupView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a parent deck with its associated subdecks in an expandable disclosure group.

import SwiftUI

/// A view that displays a disclosure group for a deck and its subdecks with actions for navigating, modifying, and deleting decks.
struct DeckDisclosureGroupView: View {
    // MARK: - Properties
    @State private var selectedDeckID: String? // Tracks the selected deck ID for deletion
    @State private var isExpanded: Bool = false // Tracks the disclosure group's expansion state
    @Binding var deck: Deck // The deck to be displayed
    @Binding var showModifyDeckButtons: Bool // Controls the visibility of modify deck buttons
    @Binding var disableModifyDeckButtons: Bool
    @Binding var subdecks: [Deck] // The subdecks associated with the parent deck
    @State private var showDeleteAlert: Bool = false

    // MARK: - Actions
    var deleteDeckAction: (String) -> Void
    var modifyDeckAction: (String) -> Void
    var navigateAction: (String) -> Void

    // MARK: - Body
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            LazyVStack(spacing: 20) {
                ForEach(subdecks) { subdeck in
                    deckButton(for: subdeck)
                        .accessibilityElement(children: .contain)
                }
            }
            .accessibilityElement(children: .contain)
        } label: {
            deckButton(
                for: deck,
                subdeckButtonAction: {
                    // Allows alternate way to control subdeck display expansion
                    if !subdecks.isEmpty {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
                }
            )
            .accessibilityElement(children: .contain)
        }
        .accessibilityIdentifier("deckDisclosureButton_\(deck.id)")
        .tint(subdecks.isEmpty ? .clear : deck.theme.primaryColor)
        .alert(isPresented: $showDeleteAlert) {
            deleteAlert
        }
        .onChange(of: subdecks) {
            // Ensures decks with 0 subdecks cannot be expanded.
            if subdecks.count == 0 {
                isExpanded = false
            }
        }
    }

    // MARK: - Private Methods
    /// Creates a button for a deck with actions for navigating, modifying, and deleting.
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
        .accessibilityIdentifier(deck.isSubdeck ? "subdeckButton_\(deck.id)" : "deckButton_\(deck.id)")
        .accessibilityLabel(deck.name)
    }
    
    /// Displays a delete deck alert when the user attempts to delete a deck.
    func removeDeckAction(id: String) {
        selectedDeckID = id
        showDeleteAlert = true
    }
    
    /// Displays a modify deck modal when the user attempts to modify a deck.
    func modifyDeckAction(id: String) {
        selectedDeckID = deck.id
        modifyDeckAction(deck.id)
    }

    // MARK: - Alert Components
    /// Displays an alert to confirm deck deletion.
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
                deleteDeckAction(deckID)
                showDeleteAlert = false
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ScrollView {
        VStack {
            DeckDisclosureGroupView(
                deck: .constant(Deck.sampleDeck),
                showModifyDeckButtons: .constant(true),
                disableModifyDeckButtons: .constant(false),
                subdecks: .constant(Deck.sampleSubdeckArray),
                deleteDeckAction: {_ in },
                modifyDeckAction: {_ in },
                navigateAction: {_ in }
            )
        }
    }
}

#Preview {
    ScrollView {
        DeckDisclosureGroupView(
            deck: .constant(Deck.sampleDeck),
            showModifyDeckButtons: .constant(false),
            disableModifyDeckButtons: .constant(false),
            subdecks: .constant(Deck.sampleSubdeckArray),
            deleteDeckAction: {_  in },
            modifyDeckAction: {_ in },
            navigateAction: {_ in }
        )
    }
}
#endif
