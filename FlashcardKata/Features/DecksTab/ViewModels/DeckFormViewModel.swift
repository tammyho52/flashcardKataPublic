//
//  DeckFormViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View model responsible for managing the creation, updating, and deletion of decks and subdecks.

import Foundation

/// A view model for managing deck operations inside a deck form.
@MainActor
final class DeckFormViewModel: ObservableObject {
    // MARK: - Properties
    @Published var initialDeck: Deck = Deck() // Initial Edit Deck Screen value store
    @Published var initialSubdecks: [Deck] = [] // Initial value store

    private var databaseManager: DatabaseManagerProtocol
    
    // MARK: - Initializer
    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }
    
    // MARK: - Deck Operation Methods
    func loadEditDeckScreenData(selectedDeckID: String?) async throws {
        guard let selectedDeckID, let selectedDeck = try await fetchDeck(id: selectedDeckID) else {
            throw AppError.networkError
        }

        initialDeck = selectedDeck
        initialSubdecks = []
        for subdeckID in selectedDeck.subdeckIDs {
            if let subdeck = try await fetchDeck(id: subdeckID) {
                initialSubdecks.append(subdeck)
            }
        }
    }
    
    func createDeck(deck: Deck) async throws {
        try await databaseManager.createDeck(deck: deck)
    }

    /// Saves updated subdeck names and themes to the database.
    func saveUpdatedSubdecks(newSubdeckNames: [SubdeckName], theme: Theme) async throws {
        // Create ID sets for old and new subdecks
        let oldIDs: Set<String> = Set(initialSubdecks.map { $0.id })
        let newIDs: Set<String> = Set(newSubdeckNames.map { $0.id })

        // Identify added, removed, and unchanged subdecks
        let addedIDs = newIDs.subtracting(oldIDs)
        let removedIDs = oldIDs.subtracting(newIDs)
        let unchangedIDs = oldIDs.intersection(newIDs)

        // Perform operations for added decks
        let addedDeckNames = newSubdeckNames.filter({ addedIDs.contains($0.id) })
        try await addSubdeckNames(subdeckNames: addedDeckNames, theme: theme)

        //  Perform operations for deleted decks
        try await removeSubdecks(with: removedIDs)

        // Sync add/remove changes to parent deck
        try await databaseManager.addSubdeckIDs(subdeckIDs: Array(addedIDs), toParentDeckID: initialDeck.id)
        try await databaseManager.deleteSubdeckIDs(subdeckIDs: Array(removedIDs), fromParentDeckID: initialDeck.id)

        // Sync changes for existing decks
        try await updateUnchangedSubdecks(unchangedIDs: unchangedIDs, newSubdeckNames: newSubdeckNames, theme: theme)
        try await databaseManager.updateDeckUpdatedDate(for: initialDeck.id)
    }
    
    /// Deletes the parent deck and all its subdecks from the database.
    func deleteDeckWithSubdecks() async throws {
        // Delete all subdecks under parent deck
        for subdeckID in initialDeck.subdeckIDs {
            try await databaseManager.deleteDeck(by: subdeckID)
        }
        // Delete parent deck
        try await databaseManager.deleteDeck(by: initialDeck.id)
    }

    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseManager.fetchDeck(for: id)
    }

    /// Updates the deck with the provided new deck object.
    func updateDeck(deck: Deck) async throws {
        try await databaseManager.updateDeckWithNewDeck(newDeck: deck)
    }

    /// Updates the deck with the provided updates.
    func updateDeck(id: String, updates: [DeckUpdate]) async throws {
        try await databaseManager.updateDeck(updates: updates, for: id)
    }

    func deleteDeck(id: String) async throws {
        try await databaseManager.deleteDeck(by: id)
    }

    func saveDeck(deck: Deck, subdeckNames: [SubdeckName]) async throws {
        // Validate deck name is available
        guard await isDeckNameAvailable(deck.name) else {
            throw AppError.validationError("Deck name already exists.")
        }
        
        // Create subdecks
        let subdecks = createSubdecks(from: subdeckNames, parentDeck: deck)
        for subdeck in subdecks {
            try await createDeck(deck: subdeck)
        }
        
        // Create parent deck
        var parentDeck: Deck = deck
        parentDeck.subdeckIDs = subdecks.map { $0.id }
        try await createDeck(deck: parentDeck)
    }
    
    // MARK: - Helper Methods
    private func isDeckNameAvailable(_ deckName: String) async -> Bool {
        return await databaseManager.isDeckNameAvailable(deckName: deckName)
    }
    
    /// Creates subdecks from the provided names and parent deck.
    private func createSubdecks(from subdeckNames: [SubdeckName], parentDeck: Deck) -> [Deck] {
        subdeckNames.map {
            Deck(id: $0.id, name: $0.name, theme: parentDeck.theme, parentDeckID: parentDeck.id)
        }
    }

    /// Creates subdecks from the provided names and parent deck ID.
    private func createSubdecks(from subdeckNames: [SubdeckName], parentDeckID: String, theme: Theme) -> [Deck] {
        subdeckNames.map {
            Deck(id: $0.id, name: $0.name, theme: theme, parentDeckID: parentDeckID)
        }
    }
    
    /// Creates subdecks from the provided names and theme.
    private func addSubdeckNames(subdeckNames: [SubdeckName], theme: Theme) async throws {
        let newSubdecks = createSubdecks(from: subdeckNames, parentDeckID: initialDeck.id, theme: theme)
        for newSubdeck in newSubdecks {
            try await databaseManager.createDeck(deck: newSubdeck)
        }
    }

    /// Removes subdecks from the database using their IDs.
    private func removeSubdecks(with ids: Set<String>) async throws {
        for removedID in ids {
            try await databaseManager.deleteDeck(by: removedID)
        }
    }

    /// Updates unchanged subdecks with new names and theme.
    private func updateUnchangedSubdecks(
        unchangedIDs: Set<String>,
        newSubdeckNames: [SubdeckName],
        theme: Theme
    ) async throws {
        let unchangedOldDecks = initialSubdecks.filter { unchangedIDs.contains($0.id) }
        let unchangedNewDeckNames = newSubdeckNames.filter { unchangedIDs.contains($0.id) }

        let isThemeUnchanged = initialDeck.theme == theme

        for oldDeck in unchangedOldDecks {
            guard let newDeckName = unchangedNewDeckNames.first(where: { $0.id == oldDeck.id }) else {
                continue
            }
            var deckUpdates: [DeckUpdate] = []
            if oldDeck.name != newDeckName.name {
                deckUpdates.append(.name(newDeckName.name))
            }
            if !isThemeUnchanged {
                deckUpdates.append(.theme(theme))
            }
            if !deckUpdates.isEmpty {
                try await databaseManager.updateDeck(updates: deckUpdates, for: oldDeck.id)
            }
        }
    }
}
