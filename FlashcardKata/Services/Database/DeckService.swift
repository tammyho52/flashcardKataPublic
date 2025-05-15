//
//  DeckService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class is responsible for managing deck data in Firebase, including fetching, updating, and deleting decks.

import Foundation
import FirebaseFirestore

/// A service for managing deck data in Firebase.
final class DeckService {
    // MARK: - Properties
    private let collectionPath: String = FirestoreCollectionPathType.deck.path
    private let databaseService: FirestoreService<Deck, Date>
    
    // MARK: - Initializer
    init() {
        self.databaseService = FirestoreService<Deck, Date>(
            collectionPathType: .deck,
            orderByKeyPath: \.updatedDate
        )
    }
    
    /// Checks if a deck name is available for a given user.
    func isDeckNameAvailable(deckName: String, userID: String) async -> Bool {
        do {
            let predicates: [QueryPredicate] = [
                .isEqualTo(field: "name", value: deckName)
            ]
            let snapshot = try await query(predicates: predicates, userID: userID)
            return snapshot.isEmpty
        } catch {
            reportError(error)
            return false
        }
    }
    
    // MARK: - Deck Fetch Methods
    /// Fetches all decks for a given user.
    func fetchAllDecks(userID: String) async throws -> [Deck] {
        return try await databaseService.fetchAll(userID: userID, documentLimit: nil)
    }
    
    /// Fetches all parent decks with corresponding subdecks for a given user.
    func fetchParentDecksWithSubDecks(userID: String) async throws -> [(Deck, [Deck])] {
        let parentDecks = try await fetchAllParentDecks(userID: userID)
        let subdecks = try await fetchAllSubdecks(userID: userID)
        
        // Group subdecks by their parentDeckID
        let subdecksByParentID = Dictionary(grouping: subdecks, by: { $0.parentDeckID })
        
        // Create an array of tuples containing parent decks and their corresponding subdecks
        let decksWithSubdecks: [(Deck, [Deck])] = parentDecks.map { parentDeck -> (Deck, [Deck]) in
            let subdecks = subdecksByParentID[parentDeck.id] ?? []
            return (parentDeck, subdecks)
        }
        return decksWithSubdecks
    }
    
    /// Fetches all parent decks for a given user.
    func fetchAllParentDecks(deckCountLimit: Int? = nil, userID: String) async throws -> [Deck] {
        let predicates: [QueryPredicate] = [
            .isNull(field: "parentDeckID")
        ]
        return try await query(predicates: predicates, userID: userID, deckCountLimit: deckCountLimit)
    }
    
    /// Fetches updated parent decks since the last updated date for a specific user.
    func fetchUpdatedParentDecks(userID: String, lastUpdatedDate: Date) async throws -> [Deck] {
        let predicates: [QueryPredicate] = [
            .isNull(field: "parentDeckID"),
            .isGreaterThan(field: "updatedDate", value: lastUpdatedDate)
        ]
        return try await query(predicates: predicates, userID: userID)
    }
    
    /// Fetches more parent decks with pagination for a specific user.
    func fetchMoreParentDecks(userID: String, lastDeckID: String) async throws -> [Deck] {
        return try await queryPaginatedDecks(
            predicates: [.isNull(field: "parentDeckID")],
            userID: userID,
            lastDocumentID: lastDeckID
        )
    }
    
    /// Fetches all subdecks for a given user.
    func fetchAllSubdecks(userID: String, deckCountLimit: Int? = nil) async throws -> [Deck] {
        let predicates: [QueryPredicate] = [
            .isNotNull(field: "parentDeckID")
        ]
        return try await query(predicates: predicates, userID: userID, deckCountLimit: deckCountLimit)
    }
    
    /// Fetches subdecks for a specific parent deck ID for a given user.
    func fetchSubDecks(userID: String, for parentDeckID: String) async throws -> [Deck] {
        let predicates: [QueryPredicate] = [
            .isEqualTo(field: "parentDeckID", value: parentDeckID)
        ]
        return try await query(predicates: predicates, userID: userID)
    }
    
    /// Fetches subdecks by their IDs.
    func fetchSubdecks(ids: [String]) async throws -> [Deck] {
        return try await fetchDecks(ids: ids)
    }

    /// Fetches a specific deck by its ID.
    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseService.fetch(id: id)
    }

    /// Fetches decks by their IDs.
    func fetchDecks(ids: [String]) async throws -> [Deck] {
        return try await databaseService.fetchDocuments(ids: ids)
    }

    /// Fetches decks matching a specific search text for a given user.
    func fetchSearchDecks(for searchText: String, userID: String) async throws -> [SearchResult] {
        let decks = try await fetchAllDecks(userID: userID)
        let filteredDecks = decks.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        
        // Order the decks by their parentDeckID and sort them by updatedDate in descending order
        let orderedDecks = orderDecksByParentDeckID(deckList: filteredDecks, orderBy: \.updatedDate, sortOperator: >)
        return orderedDecks.map { SearchResult(deck: $0) }
    }

    // MARK: - Deck CRUD Methods
    func createDeck(deck: Deck) async throws {
        try await databaseService.create(deck)
    }

    func updateDeck(deck: Deck) async throws {
        try await databaseService.updateDocument(deck)
    }

    func updateDeck(id: String, deckUpdates: [DeckUpdate]) async throws {
        let firestoreDeckUpdates = convertDeckUpdateToDatabase(updates: deckUpdates)
        try await databaseService.updateDocumentFields(id: id, updates: firestoreDeckUpdates)
    }
    
    func deleteDeck(id: String) async throws {
        try await databaseService.delete(id: id)
    }
    
    func deleteAllDecks(userID: String) async throws {
        try await databaseService.deleteAll(userID: userID)
    }
    
    // MARK: - Deck Query Methods
    /// Queries decks based on specified predicates and user ID.
    func query(
        predicates: [QueryPredicate] = [],
        userID: String,
        deckCountLimit: Int? = nil
    ) async throws -> [Deck] {
        return try await databaseService.query(
            predicates: predicates,
            userID: userID,
            documentLimit: deckCountLimit
        )
    }
    
    /// Queries decks with pagination based on specified predicates and user ID.
    func queryPaginatedDecks(
        predicates: [QueryPredicate],
        userID: String,
        lastDocumentID: String
    ) async throws -> [Deck] {
        try await databaseService.queryPaginatedDocuments(
            predicates: predicates,
            userID: userID,
            lastDocumentID: lastDocumentID
        )
    }
    
    // MARK: - Helper Methods
    /// Sets up deck updates to be sent to Firestore.
    private func convertDeckUpdateToDatabase(updates: [DeckUpdate]) -> [DatabaseUpdate] {
        var databaseUpdates: [DatabaseUpdate] = []

        for update in updates {
            switch update {
            case .name(let name):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: name))
                databaseUpdates.append(firestoreUpdate)
            case .theme(let theme):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: theme))
                databaseUpdates.append(firestoreUpdate)
            case .parentDeckID(let parentDeckID):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: parentDeckID))
                databaseUpdates.append(firestoreUpdate)
            case .subdeckIDs(let idUpdate):
                handleIDUpdate(field: update.key, idUpdate: idUpdate, databaseUpdates: &databaseUpdates)
            case .flashcardIDs(let idUpdate):
                handleIDUpdate(field: update.key, idUpdate: idUpdate, databaseUpdates: &databaseUpdates)
            case .reviewedFlashcardIDs(let idUpdate):
                handleIDUpdate(field: update.key, idUpdate: idUpdate, databaseUpdates: &databaseUpdates)
            case .lastReviewedDate(let recentReviewedDate):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: recentReviewedDate))
                databaseUpdates.append(firestoreUpdate)
            case .updatedDate(let updatedDate):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: updatedDate))
                databaseUpdates.append(firestoreUpdate)
            }
        }
        return databaseUpdates
    }

    /// Handles ID updates for subdeckIDs and flashcardIDs to be sent to Firestore.
    private func handleIDUpdate(field: String, idUpdate: IDUpdate, databaseUpdates: inout [DatabaseUpdate]) {
        if !idUpdate.addIDs.isEmpty {
            let firestoreAddIDs = idUpdate.addIDs
            let addUpdate = DatabaseUpdate(field: field, operation: .add(values: firestoreAddIDs))
            databaseUpdates.append(addUpdate)
        }
        if !idUpdate.removeIDs.isEmpty {
            let firestoreRemoveIDs = idUpdate.removeIDs
            let removeUpdate = DatabaseUpdate(field: field, operation: .remove(values: firestoreRemoveIDs))
            databaseUpdates.append(removeUpdate)
        }
    }
}
