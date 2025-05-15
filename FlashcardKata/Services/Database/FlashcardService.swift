//
//  FlashcardService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class is responsible for managing flashcard data in Firebase.

import Foundation
import FirebaseFirestore

/// A service for managing flashcard data in Firebase.
final class FlashcardService {
    // MARK: - Properties
    private let collectionPath: String = FirestoreCollectionPathType.flashcard.path
    private let databaseService: FirestoreService<Flashcard, Date>

    // MARK: - Initializer
    init() {
        self.databaseService = FirestoreService<Flashcard, Date>(
            collectionPathType: .flashcard,
            orderByKeyPath: \.updatedDate
        )
    }
    
    /// Fetches all flashcards for a given user ID.
    func fetchAllFlashcards(userID: String, documentLimit: Int? = nil) async throws -> [Flashcard] {
        return try await databaseService.fetchAll(userID: userID, documentLimit: documentLimit)
    }
    
    /// Fetches flashcards for a specific deck ID.
    func fetchFlashcards(userID: String, for deckID: String) async throws -> [Flashcard] {
        let predicates: [QueryPredicate] = [
            .isEqualTo(field: "deckID", value: deckID)
        ]
        return try await query(predicates: predicates, userID: userID)
    }

    /// Checks if the user has flashcards.
    func hasFlashcards(userID: String) async -> Bool {
        return await databaseService.hasDocument(userID: userID)
    }

    func createFlashcard(flashcard: Flashcard) async throws {
        try await databaseService.create(flashcard)
    }
    
    /// Updates the provided flashcard in the database.
    func updateFlashcard(flashcard: Flashcard) async throws {
        try await databaseService.updateDocument(flashcard)
    }

    /// Updates flashcard fields using the provided updates.
    func updateFlashcard(id: String, flashcardUpdates: [FlashcardUpdate]) async throws {
        let firestoreFlashcardUpdates = convertFlashcardUpdateToDatabase(updates: flashcardUpdates)
        try await databaseService.updateDocumentFields(id: id, updates: firestoreFlashcardUpdates)
    }
    
    /// Updates the updated date of the flashcard.
    func updateFlashcardUpdatedDate(id: String) async throws {
        let flashcardUpdates: [FlashcardUpdate] = [.updatedDate(Date())]
        try await updateFlashcard(id: id, flashcardUpdates: flashcardUpdates)
    }

    /// Converts flashcard updates to database updates for storage in Firestore.
    private func convertFlashcardUpdateToDatabase(updates: [FlashcardUpdate]) -> [DatabaseUpdate] {
        var databaseUpdates: [DatabaseUpdate] = []

        for update in updates {
            switch update {
            case .deckID(let deckID):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: deckID))
                databaseUpdates.append(firestoreUpdate)
            case .frontText(let frontText):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: frontText))
                databaseUpdates.append(firestoreUpdate)
            case .backText(let backText):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: backText))
                databaseUpdates.append(firestoreUpdate)
            case .hint(let hint):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: hint))
                databaseUpdates.append(firestoreUpdate)
            case .notes(let notes):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: notes))
                databaseUpdates.append(firestoreUpdate)
            case .difficultyLevel(let difficultyLevel):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: difficultyLevel))
                databaseUpdates.append(firestoreUpdate)
            case .updatedDate(let updatedDate):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: updatedDate))
                databaseUpdates.append(firestoreUpdate)
            case .recentReviewedDate(let recentReviewedDate):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .update(value: recentReviewedDate))
                databaseUpdates.append(firestoreUpdate)
            case .correctReviewCount(let correctReviewCount):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .increment(value: correctReviewCount))
                databaseUpdates.append(firestoreUpdate)
            case .incorrectReviewCount(let incorrectReviewCount):
                let firestoreUpdate = DatabaseUpdate(field: update.key, operation: .increment(value: incorrectReviewCount))
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

    /// Fetches flashcards that match the search text.
    func fetchSearchFlashcards(for searchText: String, userID: String) async throws -> [Flashcard] {
        let caseInsensitiveSearchText = searchText.lowercased()
        let flashcards = try await fetchAllFlashcards(userID: userID)
        // Filter on client side due to Firestore limitations for "contains substring" and case-insensitive searches.
        let filteredFlashcards = flashcards.filter {
            $0.frontText.lowercased().contains(caseInsensitiveSearchText)
            || $0.backText.lowercased().contains(caseInsensitiveSearchText)
        }
        return filteredFlashcards.sorted { $0.updatedDate > $1.updatedDate }
    }

    /// Queries flashcards based on the provided predicates.
    func query(predicates: [QueryPredicate] = [], userID: String) async throws -> [Flashcard] {
        return try await databaseService.query(predicates: predicates, userID: userID)
    }

    /// Queries flashcards with pagination support.
    func queryPaginatedFlashcards(
        predicates: [QueryPredicate],
        userID: String,
        lastDocumentID: String
    ) async throws -> [Flashcard] {
        try await databaseService.queryPaginatedDocuments(
            predicates: predicates,
            userID: userID,
            lastDocumentID: lastDocumentID
        )
    }

    /// Deletes all flashcards for a given user ID.
    func deleteAllFlashcards(userID: String) async throws {
        try await databaseService.deleteAll(userID: userID)
    }
}
