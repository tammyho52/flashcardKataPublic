//
//  DeckService.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation
import FirebaseFirestore

final class DeckService {
    
    private let collectionPath: String = FirestoreCollectionPath.deck.path
    private let databaseService: FirestoreService<Deck, Date>
    
    init() {
        self.databaseService = FirestoreService<Deck, Date>(collectionPath: collectionPath, orderByKeyPath: \Deck.updatedDate, orderDirection: .descending)
    }
    
    func fetchAllDecks(userID: String) async throws -> [Deck] {
        return try await databaseService.fetchAll(userID: userID)
    }
    
    func createDeck(deck: Deck) async throws {
        try await databaseService.create(deck)
    }
    
    func updateDeck(deck: Deck) async throws {
        try await databaseService.update(deck)
    }
    
    func updateDeck(id: String, deckUpdates: [DeckUpdate]) async throws {
        let firestoreDeckUpdates = convertDeckUpdateToDatabase(updates: deckUpdates)
        try await databaseService.updateDocument(id: id, updates: firestoreDeckUpdates)
    }
    
    private func convertDeckUpdateToDatabase(updates: [DeckUpdate]) -> [FirestoreUpdate] {
        var databaseUpdates: [FirestoreUpdate] = []
        
        for update in updates {
            switch update {
            case .name(let name):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: name))
                databaseUpdates.append(firestoreUpdate)
            case .theme(let theme):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: theme))
                databaseUpdates.append(firestoreUpdate)
            case .parentDeckID(let parentDeckID):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: parentDeckID))
                databaseUpdates.append(firestoreUpdate)
            case .subdeckIDs(let idUpdate):
                handleIDUpdate(field: update.key, idUpdate: idUpdate, databaseUpdates: &databaseUpdates)
            case .flashcardIDs(let idUpdate):
                handleIDUpdate(field: update.key, idUpdate: idUpdate, databaseUpdates: &databaseUpdates)
            case .lastReviewedDate(let recentReviewedDate):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: recentReviewedDate))
                databaseUpdates.append(firestoreUpdate)
            case .updatedDate(let updatedDate):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: updatedDate))
                databaseUpdates.append(firestoreUpdate)
            }
        }
        return databaseUpdates
    }
    
    private func handleIDUpdate(field: String, idUpdate: IDUpdate, databaseUpdates: inout [FirestoreUpdate]) {
        if !idUpdate.addIDs.isEmpty {
            let firestoreAddIDs = idUpdate.addIDs
            let addUpdate = FirestoreUpdate(field: field, operation: .add(values: firestoreAddIDs))
            databaseUpdates.append(addUpdate)
        }
        if !idUpdate.removeIDs.isEmpty {
            let firestoreRemoveIDs = idUpdate.removeIDs
            let removeUpdate = FirestoreUpdate(field: field, operation: .remove(values: firestoreRemoveIDs))
            databaseUpdates.append(removeUpdate)
        }
    }
    
    func deleteDeck(id: String) async throws {
        try await databaseService.delete(id: id)
    }
    
    func fetchDeck(id: String) async throws -> Deck? {
        return try await databaseService.fetch(id: id)
    }
    
    func fetchDecks(ids: [String]) async throws -> [Deck] {
        return try await databaseService.fetchDocuments(ids: ids)
    }
    
    /// Includes deck ordering by `orderDecksByParentDeckID`
    func fetchSearchDecks(for searchText: String, userID: String) async throws -> [SearchResult] {
        let decks = try await fetchAllDecks(userID: userID)
        let filteredDecks = decks.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        let orderedDecks = orderDecksByParentDeckID(deckList: filteredDecks, orderBy: \.updatedDate, sortOperator: >)
        return orderedDecks.map { SearchResult(deck: $0) }
    }
    
    func query(predicates: [QueryPredicate] = [], userID: String, deckCountLimit: Int? = nil) async throws -> [Deck] {
        return try await databaseService.query(predicates: predicates, userID: userID, documentLimit: deckCountLimit)
    }
    
    func query(firstPredicates: [QueryPredicate], secondPredicates: [QueryPredicate], userID: String) async throws -> [Deck] {
        return try await databaseService.query(firstPredicates: firstPredicates, secondPredicates: secondPredicates, userID: userID)
    }
    
    func queryCount(predicates: [QueryPredicate] = [], userID: String) async throws -> Int {
        return try await databaseService.queryCount(predicates: predicates, userID: userID)
    }
    
    func queryPaginatedDecks(predicates: [QueryPredicate], userID: String, lastDocument: DocumentSnapshot?) async throws -> [Deck] {
        try await databaseService.queryPaginatedDocuments(predicates: predicates, userID: userID, lastDocument: lastDocument)
    }
    
    func isDeckNameAvailable(deckName: String, userID: String) async throws -> Bool {
        let predicates: [QueryPredicate] = [
            .isEqualTo(field: "name", value: deckName)
        ]
        let snapshot = try await query(predicates: predicates, userID: userID)
        return snapshot.isEmpty
    }
    
    func deleteAllDecks(userID: String) async throws {
        try await databaseService.deleteAll(userID: userID)
    }
    
    func getLastDocumentSnapshot(id: String?) async throws -> DocumentSnapshot? {
        try await databaseService.getLastDocumentSnapshot(id: id)
    }
}
