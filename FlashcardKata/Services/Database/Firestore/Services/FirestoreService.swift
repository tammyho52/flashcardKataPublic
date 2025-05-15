//
//  FirebaseContext.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure that abstracts interactions with Firestore for CRUD operations, fetch operations, and queries.

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

/// A generic service for managing Firestore operations for a specific document type.
struct FirestoreService<Document: Firestorable, T: Comparable>: DatabaseService {
    // MARK: - Properties
    let firestore: Firestore
    let collectionPath: String
    let orderByKeyPath: KeyPath<Document, T>
    let crudService: FirestoreCRUDService<Document>
    let queryService: FirestoreQueryService<Document, T>
    
    // MARK: - Initialization
    init(
        firestore: Firestore = Firestore.firestore(),
        collectionPathType: FirestoreCollectionPathType,
        orderByKeyPath: KeyPath<Document, T>
    ) {
        self.firestore = firestore
        self.collectionPath = collectionPathType.path
        self.orderByKeyPath = orderByKeyPath
        self.crudService = FirestoreCRUDService(
            firestore: firestore,
            collectionPathType: collectionPathType
        )
        self.queryService = FirestoreQueryService(
            firestore: firestore,
            collectionPathType: collectionPathType,
            orderByKeyPath: orderByKeyPath
        )
    }

    // MARK: - CRUD Service Methods
    /// Creates a new document in Firestore.
    /// - Parameter document: The document to be created.
    func create(_ document: Document) async throws {
        do {
            try await crudService.create(document)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    /// Updates an existing document in Firestore.
    /// - Parameter document: The document to be updated.
    func updateDocument(_ document: Document) async throws {
        do {
            try await crudService.updateDocument(document)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    /// Updates specific fields of a document in Firestore.
    /// - Parameters:
    ///   - id: The ID of the document to be updated.
    ///   - updates: The updates to be applied to the document.
    func updateDocumentFields(id: String, updates: [DatabaseUpdate]) async throws {
        do {
            try await crudService.updateDocumentFields(id: id, updates: updates)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    /// Deletes a document from Firestore.
    /// - Parameter id: The ID of the document to be deleted.
    func delete(id: String) async throws {
        do {
            try await crudService.delete(id: id)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    // MARK: - Combined Methods
    /// Deletes all documents associated with a specific user ID.
    /// - Parameter userID: The user ID whose documents are to be deleted.
    func deleteAll(userID: String) async throws {
        do {
            let documents = try await fetchAll(userID: userID)
            if !documents.isEmpty {
                let documentBatches = createDocumentBatches(documents: documents, batchSize: 50)
                for batch in documentBatches {
                    try Task.checkCancellation()
                    let writeBatch = firestore.batch()
                    for document in batch {
                        let docRef = firestore.collection(collectionPath).document(document.id)
                        writeBatch.deleteDocument(docRef)
                    }
                    try await writeBatch.commit()
                }
            }
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    // MARK: - Query Service Methods
    /// Fetches all documents associated with a specific user ID.
    /// - Parameters:
    ///   - userID: The user ID whose documents are to be fetched.
    ///   - documentLimit: The maximum number of documents to fetch. If nil, fetch all documents.
    /// - Returns: An array of documents.
    func fetchAll(userID: String, documentLimit: Int? = nil) async throws -> [Document] {
        do {
            return try await queryService.fetchAll(userID: userID, documentLimit: documentLimit)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    /// Fetches a document by its ID.
    /// - Parameter id: The ID of the document to be fetched.
    /// - Returns: The fetched document, or nil if not found.
    func fetch(id: String) async throws -> Document? {
        do {
            return try await queryService.fetch(id: id)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }

    /// Fetches multiple documents by their IDs.
    /// - Parameter ids: The IDs of the documents to be fetched.
    /// - Returns: An array of fetched documents.
    func fetchDocuments(ids: [String]) async throws -> [Document] {
        do {
            return try await queryService.fetchDocuments(ids: ids)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }

    /// Queries documents based on the provided predicates.
    /// - Parameters:
    ///   - predicates: The query predicates to apply.
    ///   - userID: The user ID whose documents are to be queried.
    ///   - documentLimit: The maximum number of documents to fetch. If nil, fetch all documents.
    /// - Returns: An array of documents that match the query.
    func query(predicates: [QueryPredicate], userID: String, documentLimit: Int? = nil) async throws -> [Document] {
        do {
            return try await queryService.query(predicates: predicates, userID: userID, documentLimit: documentLimit)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    /// Queries documents based on the provided predicates and paginates the results.
    /// - Parameters:
    ///   - predicates: The query predicates to apply.
    ///   - userID: The user ID whose documents are to be queried.
    ///   - lastDocumentID: The ID of the last document from the previous query, used for pagination.
    /// - Returns: An array of documents that match the query.
    func queryPaginatedDocuments(
        predicates: [QueryPredicate],
        userID: String,
        lastDocumentID: String
    ) async throws -> [Document] {
        do {
            return try await queryService.queryPaginatedDocuments(predicates: predicates, userID: userID, lastDocumentID: lastDocumentID)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    /// Checks if a document exists for the given user ID.
    /// - Parameter userID: The user ID to check for document existence.
    /// - Returns: A boolean indicating whether the document exists.
    func hasDocument(userID: String) async -> Bool {
        return await queryService.hasDocument(userID: userID)
    }
    
    /// Checks if a document exists based on the provided predicates and user ID.
    /// - Parameters:
    ///   - predicates: The query predicates to apply.
    ///   - userID: The user ID to check for document existence.
    /// - Returns: A boolean indicating whether a document exists.
    func hasDocument(predicates: [QueryPredicate], userID: String) async throws -> Bool {
        do {
            return try await queryService.hasDocument(predicates: predicates, userID: userID)
        } catch {
            throw handleFirestoreNSError(error)
        }
    }
    
    // MARK: - Helper Methods
    /// Creates batches of documents for batch processing.
    /// - Parameters:
    ///   - documents: The documents to be batched.
    ///   - batchSize: The maximum size of each batch. Defaults to `ContentConstants.fetchItemLimit`.
    /// - Returns: An array of batches, each containing an array of documents.
    private func createDocumentBatches(documents: [Document], batchSize: Int = ContentConstants.fetchItemLimit) -> [[Document]] {
        let batchSize = batchSize
        let batches = stride(from: 0, to: documents.count, by: batchSize).map {
            Array(documents[$0 ..< min($0 + batchSize, documents.count)])
        }
        return batches
    }
    
    // MARK: - Error Handling
    /// Handles Firestore errors by converting them to `AppError`.
    /// - Parameter error: The error to be handled.
    /// - Returns: The corresponding `AppError`.
    func handleFirestoreNSError(_ error: Error) -> AppError {
        // Convert the error to NSError to get the error code
        let nsError = error as NSError
        
        // Check if the error is a Firestore error
        if let _ = FirestoreErrorCode.Code(rawValue: nsError.code) {
            // Handle Firestore errors
            let firestoreError = FirestoreErrorCode(_nsError: nsError)
            return handleFirestoreError(firestoreError)
        } else {
            // Return a system error for non-Firestore errors
            return .systemError
        }
    }
    
    /// Converts Firestore errors to `AppError`.
    /// - Parameter error: The Firestore error to be handled.
    /// - Returns: The corresponding `AppError`.
    private func handleFirestoreError(_ error: FirestoreErrorCode) -> AppError {
        switch error.code {
        case .unauthenticated, .permissionDenied:
            return .permissionError
        case .alreadyExists:
            return .validationError("The data already exists.")
        case .invalidArgument:
            return .validationError("The data is invalid.")
        case .notFound, .outOfRange, .unavailable, .deadlineExceeded:
            return .networkError
        default:
            return .systemError
        }
    }
}
