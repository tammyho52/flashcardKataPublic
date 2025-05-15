//
//  FirestoreQueryService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This structure abstracts interactions with Firestore for fetch operations and queries.

import Foundation
import FirebaseFirestore

/// A generic service for performing fetch operations and queries on Firestore documents.
struct FirestoreQueryService<Document: Firestorable, T: Comparable> {
    // MARK: - Properties
    let firestore: Firestore
    let collectionPath: String
    let orderByKeyPath: KeyPath<Document, T>
    let defaultSort: SortOrder = .descending
    
    /// The default sort order for the documents.
    private var defaultOrderQueryPredicate: QueryPredicate {
        let orderByField = Document.firestoreFieldName(for: orderByKeyPath)
        return QueryPredicate.orderBy(field: orderByField, descending: defaultSort == .descending)
    }
    
    // MARK: - Initializer
    init(
        firestore: Firestore = Firestore.firestore(),
        collectionPathType: FirestoreCollectionPathType,
        orderByKeyPath: KeyPath<Document, T>
    ) {
        self.firestore = firestore
        self.collectionPath = collectionPathType.path
        self.orderByKeyPath = orderByKeyPath
    }
    
    /// Fetch all documents for a specific user.
    /// - Parameters:
    ///   - userID: The ID of the user whose documents are to be fetched.
    ///   - documentLimit: The maximum number of documents to fetch. If nil, all documents are fetched.
    /// - Returns: An array of documents.
    func fetchAll(userID: String, documentLimit: Int? = nil) async throws -> [Document] {
        return try await query(predicates: [], userID: userID, documentLimit: documentLimit)
    }
    
    /// Fetch a document by its ID.
    /// - Parameter id: The ID of the document to fetch.
    /// - Returns: The fetched document, or nil if not found.
    func fetch(id: String) async throws -> Document? {
        let reference = firestore.collection(collectionPath)
        let snapshot = try await reference.document(id).getDocument()
        if snapshot.exists {
            return try snapshot.data(as: Document.self)
        } else {
            return nil
        }
    }
    
    /// Fetch documents by their IDs.
    /// - Parameter ids: The IDs of the documents to fetch.
    /// - Returns: An array of fetched documents.
    func fetchDocuments(ids: [String]) async throws -> [Document] {
        var allDocuments: [Document] = []

        // Create batches of IDs to avoid exceeding Firestore's limit for the "in" operator
        let idBatches = createIDBatches(ids: ids)
        
        // Fetch documents in batches
        for batch in idBatches {
            try Task.checkCancellation()
            let query = firestore.collection(collectionPath).whereField(FieldPath.documentID(), in: batch)
            let snapshot = try await query.getDocuments()
            let documents = snapshot.documents.compactMap { try? $0.data(as: Document.self) }
            allDocuments.append(contentsOf: documents)
        }
        return sortedByDefault(allDocuments)
    }
    
    /// Query documents based on specified predicates.
    /// - Parameters:
    ///   - predicates: The query predicates to apply.
    ///   - userID: The ID of the user whose documents are to be fetched.
    ///   - documentLimit: The maximum number of documents to fetch. If nil, all documents are fetched.
    /// - Returns: An array of documents that match the query.
    func query(
        predicates: [QueryPredicate],
        userID: String,
        documentLimit: Int? = nil
    ) async throws -> [Document] {
        var allDocuments: [Document] = []
        var lastDocumentSnapshot: DocumentSnapshot?
        var isLastBatch = false
        
        // Continues fetching documents until the last batch is reached
        while !isLastBatch {
            try Task.checkCancellation()
            
            if let documentLimit, allDocuments.count >= documentLimit {
                allDocuments = Array(allDocuments.prefix(documentLimit))
                break
            }
            
            let batchQuery = try await createQuery(predicates: predicates, userID: userID, lastDocument: lastDocumentSnapshot)
            let snapshot = try await batchQuery.getDocuments()
            if !snapshot.isEmpty {
                lastDocumentSnapshot = snapshot.documents.last
                let documents = snapshot.documents.compactMap { try? $0.data(as: Document.self) }
                allDocuments.append(contentsOf: documents)
                isLastBatch = snapshot.documents.count < ContentConstants.fetchItemLimit
            } else {
                isLastBatch = true
            }
        }
        return allDocuments
    }
    
    /// Queries paginated documents based on specified predicates.
    /// - Parameters:
    ///   - predicates: The query predicates to apply.
    ///   - userID: The ID of the user whose documents are to be fetched.
    ///   - lastDocumentID: The ID of the last document from the previous batch.
    /// - Returns: An array of documents that match the query.
    func queryPaginatedDocuments(
        predicates: [QueryPredicate],
        userID: String,
        lastDocumentID: String
    ) async throws -> [Document] {
        guard let lastDocumentSnapshot = try await getLastDocumentSnapshot(id: lastDocumentID) else { return [] }
        
        let query = try await createQuery(predicates: predicates, userID: userID, lastDocument: lastDocumentSnapshot)
        let snapshot = try await query.getDocuments()
        if !snapshot.isEmpty {
            return snapshot.documents.compactMap { try? $0.data(as: Document.self) }
        } else {
            return []
        }
    }
    
    /// Checks if any document exists for a specific user.
    /// - Parameter userID: The ID of the user whose documents are to be checked.
    /// - Returns: A boolean indicating whether any document exists.
    func hasDocument(userID: String) async -> Bool {
        do {
            let query: Query = try await createQuery(predicates: [.limitTo(field: 1)], userID: userID)
            let snapshot = try await query.getDocuments()
            return snapshot.count == 1
        } catch {
            reportError(error)
            return false
        }
    }
    
    /// Checks if any document exists based on specified predicates.
    /// - Parameters:
    ///   - predicates: The query predicates to apply.
    ///   - userID: The ID of the user whose documents are to be checked.
    /// - Returns: A boolean indicating whether any document exists.
    func hasDocument(predicates: [QueryPredicate], userID: String) async throws -> Bool {
        let query = try await createQuery(predicates: predicates, userID: userID)
        let snapshot = try await query.getDocuments()
        return !snapshot.isEmpty
    }
    
    // MARK: - Helper Methods
    /// Retrieves the last document snapshot based on its ID.
    /// - Parameter id: The ID of the document.
    /// - Returns: The last document snapshot, or nil if not found.
    private func getLastDocumentSnapshot(id: String?) async throws -> DocumentSnapshot? {
        guard let id else { return nil }
        let docRef = firestore.collection(collectionPath).document(id)
        return try await docRef.getDocument()
    }
    
    /// Sorts documents by the default order.
    /// - Parameter documents: The documents to sort.
    /// - Returns: A sorted array of documents.
    private func sortedByDefault(_ documents: [Document]) -> [Document] {
        if defaultSort == .descending {
            return documents.sorted { $0[keyPath: orderByKeyPath] > $1[keyPath: orderByKeyPath] }
        } else {
            return documents.sorted { $0[keyPath: orderByKeyPath] < $1[keyPath: orderByKeyPath] }
        }
    }
    
    /// Creates a query based on specified predicates and user ID.
    /// - Parameters:
    ///   - predicates: The query predicates to apply.
    ///   - userID: The ID of the user whose documents are to be fetched.
    ///   - lastDocument: The last document snapshot from the previous batch, if any.
    /// - Returns: The created Firestore query.
    private func createQuery(
        predicates: [QueryPredicate],
        userID: String,
        lastDocument: DocumentSnapshot? = nil
    ) async throws -> Query {
        var query: Query = firestore.collection(collectionPath)

        for predicate in predicates {
            query = apply(predicate: predicate, to: query)
        }
        
        query = query.whereField("userID", isEqualTo: userID)
        
        if !containsOrderByQueryPredicate(for: predicates) {
            query = apply(predicate: defaultOrderQueryPredicate, to: query)
        }

        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        if !containsLimitToQueryPredicate(for: predicates) {
            query = query.limit(to: ContentConstants.fetchItemLimit)
        }
        return query
    }
    
    /// Applies a query predicate to a Firestore query.
    /// - Parameters:
    ///   - predicate: The query predicate to apply.
    ///   - query: The base Firestore query.
    /// - Returns: The updated Firestore query with the predicate applied.
    private func apply(predicate: QueryPredicate, to query: Query) -> Query {
        return FirestoreQueryPredicateBuilder.buildQuery(from: predicate, for: query)
    }
    
    /// Checks if a specific predicate exists in the provided predicates array.
    /// - Parameters:
    ///   - predicates: The list of query predicates to check.
    ///   - type: The type of predicate to check for.
    /// - Returns: A boolean indicating whether the predicate exists.
    private func containsPredicate(for predicates: [QueryPredicate], of type: QueryPredicate) -> Bool {
        return predicates.contains { $0 == type }
    }
    
    /// Check if the predicates contain an orderBy predicate.
    /// - Parameter predicates: The list of query predicates to check.
    /// - Returns: A boolean indicating whether an orderBy predicate exists.
    private func containsOrderByQueryPredicate(for predicates: [QueryPredicate]) -> Bool {
        if containsPredicate(for: predicates, of: .orderBy(field: "", descending: true)) {
            return true
        } else {
            return false
        }
    }
    
    /// Check if the predicates contain a limitTo predicate.
    /// - Parameter predicates: The list of query predicates to check.
    /// - Returns: A boolean indicating whether a limitTo predicate exists.
    private func containsLimitToQueryPredicate(for predicates: [QueryPredicate]) -> Bool {
        for predicate in predicates {
            switch predicate {
            case .limitTo:
                return true
            default:
                continue
            }
        }
        return false
    }
    
    /// Creates batches of IDs for batch fetching.
    /// - Parameters:
    ///   - ids: The array of IDs to batch.
    ///   - batchSize: The maximum size of each batch.
    /// - Returns: An array of arrays, each containing a batch of IDs.
    private func createIDBatches(ids: [String], batchSize: Int = ContentConstants.fetchItemLimit) -> [[String]] {
        let batches = stride(from: 0, to: ids.count, by: batchSize).map {
            Array(ids[$0 ..< min($0 + batchSize, ids.count)])
        }
        return batches
    }
}
