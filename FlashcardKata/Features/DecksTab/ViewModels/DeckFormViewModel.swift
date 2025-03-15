//
//  DeckFormViewModel.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View model responsible for managing deck creation, updates, and deletion,
//  including handling subdecks and database interactions.

import Foundation

final class DeckFormViewModel: ObservableObject {

    @Published var initialDeck: Deck = Deck() // Initial Edit Deck Screen value store
    @Published var initialSubdecks: [Deck] = [] // Initial value store

    private var databaseManager: DatabaseManagerProtocol

    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }

    @MainActor
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

    @MainActor
    func saveUpdatedSubdecks(newSubdeckNames: [SubdeckName], theme: Theme) async throws {
        // Calculate IDs
        let oldIDs: Set<String> = Set(initialSubdecks.map { $0.id })
        let newIDs: Set<String> = Set(newSubdeckNames.map { $0.id })

        let addedIDs = newIDs.subtracting(oldIDs)
        let removedIDs = oldIDs.subtracting(newIDs)
        let unchangedIDs = oldIDs.intersection(newIDs)

        let addedDeckNames = newSubdeckNames.filter({ addedIDs.contains($0.id) })
        try await addSubdeckNames(subdeckNames: addedDeckNames, theme: theme)

        // Remove deleted decks
        try await removeSubdecks(with: removedIDs)

        // Sync changes to parent deck
        try await databaseManager.addSubdeckIDs(subdeckIDs: Array(addedIDs), toParentDeckID: initialDeck.id)
        try await databaseManager.deleteSubdeckIDs(subdeckIDs: Array(removedIDs), fromParentDeckID: initialDeck.id)

        // Update changes for existing decks
        try await updateUnchangedSubdecks(unchangedIDs: unchangedIDs, newSubdeckNames: newSubdeckNames, theme: theme)
        try await databaseManager.updateDeckUpdatedDate(for: initialDeck.id)
    }

    @MainActor
    func deleteDeckWithSubdecks() async throws {
        // Delete all subdecks under parent deck
        for subdeckID in initialDeck.subdeckIDs {
            try await databaseManager.deleteDeck(by: subdeckID)
        }
        // Delete parent deck
        try await databaseManager.deleteDeck(by: initialDeck.id)
    }

    private func addSubdeckNames(subdeckNames: [SubdeckName], theme: Theme) async throws {
        let newSubdecks = createSubdecks(from: subdeckNames, parentDeckID: initialDeck.id, theme: theme)
        for newSubdeck in newSubdecks {
            try await databaseManager.createDeck(deck: newSubdeck)
        }
    }

    private func removeSubdecks(with ids: Set<String>) async throws {
        for removedID in ids {
            try await databaseManager.deleteDeck(by: removedID)
        }
    }

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

    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseManager.fetchDeck(for: id)
    }

    func updateDeck(deck: Deck) async throws {
        try await databaseManager.updateDeck(newDeck: deck)
    }

    func updateDeck(id: String, updates: [DeckUpdate]) async throws {
        try await databaseManager.updateDeck(updates: updates, for: id)
    }

    func deleteDeck(id: String) async throws {
        try await databaseManager.deleteDeck(by: id)
    }

    func saveDeck(deck: Deck, subdeckNames: [SubdeckName]) async throws {
        // Validate input
        guard try await isDeckNameAvailable(deck.name) else {
            throw AppError.invalidInput(message: "deck name")
        }

        do {
            let subdecks = createSubdecks(from: subdeckNames, parentDeck: deck)
            for subdeck in subdecks {
                try await createDeck(deck: subdeck)
            }
            var parentDeck: Deck = deck
            parentDeck.subdeckIDs = subdecks.map { $0.id }
            try await createDeck(deck: parentDeck)
        } catch {
            throw AppError.networkError
        }
    }

    func isDeckNameAvailable(_ deckName: String) async throws -> Bool {
        return try await databaseManager.isDeckNameAvailable(deckName: deckName)
    }

    func createSubdecks(from subdeckNames: [SubdeckName], parentDeck: Deck) -> [Deck] {
        subdeckNames.map {
            Deck(id: $0.id, name: $0.name, theme: parentDeck.theme, parentDeckID: parentDeck.id)
        }
    }

    func createSubdecks(from subdeckNames: [SubdeckName], parentDeckID: String, theme: Theme) -> [Deck] {
        subdeckNames.map {
            Deck(id: $0.id, name: $0.name, theme: theme, parentDeckID: parentDeckID)
        }
    }
}
