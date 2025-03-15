//
//  FlashcardService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Class responsible for managing flashcard data in Firebase.

import Foundation
import FirebaseFirestore

final class FlashcardService {
    private let collectionPath: String = FirestoreCollectionPath.flashcard.path
    private let databaseService: FirestoreService<Flashcard, Date>

    init() {
        self.databaseService = FirestoreService<Flashcard, Date>(
            collectionPath: collectionPath,
            orderByKeyPath: \.updatedDate,
            orderDirection: .descending
        )
    }

    func fetchAllFlashcards(userID: String, documentLimit: Int? = nil) async throws -> [Flashcard] {
        return try await databaseService.fetchAll(userID: userID, documentLimit: documentLimit)
    }

    func hasFlashcards(userID: String) async throws -> Bool {
        return try await databaseService.hasDocument(userID: userID)
    }

    func createFlashcard(flashcard: Flashcard) async throws {
        try await databaseService.create(flashcard)
    }

    func updateFlashcard(flashcard: Flashcard) async throws {
        try await databaseService.update(flashcard)
    }

    func updateFlashcard(id: String, flashcardUpdates: [FlashcardUpdate]) async throws {
        let firestoreFlashcardUpdates = convertFlashcardUpdateToDatabase(updates: flashcardUpdates)
        try await databaseService.updateDocument(id: id, updates: firestoreFlashcardUpdates)
    }

    private func convertFlashcardUpdateToDatabase(updates: [FlashcardUpdate]) -> [FirestoreUpdate] {
        var databaseUpdates: [FirestoreUpdate] = []

        for update in updates {
            switch update {
            case .deckID(let deckID):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: deckID))
                databaseUpdates.append(firestoreUpdate)
            case .frontText(let frontText):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: frontText))
                databaseUpdates.append(firestoreUpdate)
            case .backText(let backText):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: backText))
                databaseUpdates.append(firestoreUpdate)
            case .hint(let hint):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: hint))
                databaseUpdates.append(firestoreUpdate)
            case .notes(let notes):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: notes))
                databaseUpdates.append(firestoreUpdate)
            case .difficultyLevel(let difficultyLevel):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: difficultyLevel))
                databaseUpdates.append(firestoreUpdate)
            case .updatedDate(let updatedDate):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: updatedDate))
                databaseUpdates.append(firestoreUpdate)
            case .recentReviewedDate(let recentReviewedDate):
                let firestoreUpdate = FirestoreUpdate(field: update.key, operation: .update(value: recentReviewedDate))
                databaseUpdates.append(firestoreUpdate)
            }
        }
        return databaseUpdates
    }

    func deleteFlashcard(id: String) async throws {
        try await databaseService.delete(id: id)
    }

    func fetchFlashcard(id: String) async throws -> Flashcard? {
        return try await databaseService.fetch(id: id)
    }

    func fetchFlashcards(ids: [String]) async throws -> [Flashcard] {
        return try await databaseService.fetchDocuments(ids: ids)
    }

    /// Filter on client side due to Firestore limitations for "contains substring" and case-insensitive searches.
    func fetchSearchFlashcards(for searchText: String, userID: String) async throws -> [Flashcard] {
        let caseInsensitiveSearchText = searchText.lowercased()
        let flashcards = try await fetchAllFlashcards(userID: userID)
        let filteredFlashcards = flashcards.filter {
            $0.frontText.lowercased().contains(caseInsensitiveSearchText)
            || $0.backText.lowercased().contains(caseInsensitiveSearchText)
        }
        return filteredFlashcards.sorted { $0.updatedDate > $1.updatedDate }
    }

    func query(predicates: [QueryPredicate] = [], userID: String) async throws -> [Flashcard] {
        return try await databaseService.query(predicates: predicates, userID: userID)
    }

    func query(
        firstPredicates: [QueryPredicate],
        secondPredicates: [QueryPredicate],
        userID: String
    ) async throws -> [Flashcard] {
        return try await databaseService.query(
            firstPredicates: firstPredicates,
            secondPredicates: secondPredicates,
            userID: userID
        )
    }

    func queryCount(predicates: [QueryPredicate], userID: String) async throws -> Int {
        return try await databaseService.queryCount(predicates: predicates, userID: userID)
    }

    func queryPaginatedFlashcards(
        predicates: [QueryPredicate],
        userID: String,
        lastDocument: DocumentSnapshot?
    ) async throws -> [Flashcard] {
        try await databaseService.queryPaginatedDocuments(
            predicates: predicates,
            userID: userID,
            lastDocument: lastDocument
        )
    }

    func fetchRandomFlashcards(userID: String) async throws -> [Flashcard] {
        return try await databaseService.fetchRandom(userID: userID)
    }

    func deleteAllFlashcards(userID: String) async throws {
        try await databaseService.deleteAll(userID: userID)
    }

    func getLastDocumentSnapshot(id: String?) async throws -> DocumentSnapshot? {
        try await databaseService.getLastDocumentSnapshot(id: id)
    }
}
