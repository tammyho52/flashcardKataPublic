//
//  FirebaseContext.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct FirestoreService<Document: Codable & Firestorable & Equatable & Hashable, T: Comparable> {
    let collectionPath: String
    let orderByKeyPath: KeyPath<Document, T>
    let orderDirection: OrderDirection
    
    var defaultOrderQueryPredicate: QueryPredicate {
        let orderByField = Document.firestoreFieldName(for: orderByKeyPath)
        return QueryPredicate.orderBy(field: orderByField, descending: orderDirection == .descending)
    }
    
    // MARK: - Create Methods
    /// Creates a new document in Firestore and associates it with the current user by `userID`.
    func create(_ document: Document) async throws {
        let reference = Firestore.firestore().collection(collectionPath).document(document.id)
        let documentData = encodeToFirestore(document: document)
        
        do {
            try await reference.setData(documentData)
        } catch {
            throw DatabaseError.createError
        }
    }
    
    // MARK: - Update Methods
    
    /// Updates an existing document in Firestore with data from the provided document.
    func update(_ document: Document) async throws {
        let reference = Firestore.firestore().collection(collectionPath)
        let documentData = encodeToFirestore(document: document)
        
        do {
            try await reference.document(document.id).setData(documentData, merge: true)
        } catch {
            throw DatabaseError.updateError
        }
    }
    
    /// Updates specific fields of a document in Firestore based on the provided operations (add, remove, update) and the operation's associated values.
    func updateDocument(id: String, updates: [FirestoreUpdate]) async throws {
        let reference = Firestore.firestore().collection(collectionPath)
        
        var updateData: [String: Any] = [:]
        
        for update in updates {
            let field = update.field
            
            switch update.operation {
            case .add(let values):
                var convertedValues: [Any] = []
                values.forEach {
                    convertedValues.append(convertToFirestoreValue(value: $0))
                }
                updateData[field] = FieldValue.arrayUnion(convertedValues)
                
            case .remove(let values):
                var convertedValues: [Any] = []
                values.forEach {
                    convertedValues.append(convertToFirestoreValue(value: $0))
                }
                updateData[field] = FieldValue.arrayRemove(convertedValues)
                
            case .update(let value):
                let convertedValue = convertToFirestoreValue(value: value)
                updateData[field] = convertedValue
            }
            try Task.checkCancellation()
        }

        do {
            try await reference.document(id).updateData(updateData)
        } catch {
            throw DatabaseError.updateError
        }
    }
    
    // MARK: - Delete Methods
    
    /// Deletes a document by its ID from Firestore.
    func delete(id: String) async throws {
        let reference = Firestore.firestore().collection(collectionPath).document(id)
        do {
            try await reference.delete()
        } catch {
            throw DatabaseError.deleteError
        }
    }
    
    func createDocumentBatches(documents: [Document], batchSize: Int = 10) -> [[Document]] {
        let batchSize = batchSize
        let batches = stride(from: 0, to: documents.count, by: batchSize).map {
            Array(documents[$0 ..< min($0 + batchSize, documents.count)])
        }
        return batches
    }
    
    func createIDBatches(ids: [String], batchSize: Int = 10) -> [[String]] {
        let batchSize = batchSize
        let batches = stride(from: 0, to: ids.count, by: batchSize).map {
            Array(ids[$0 ..< min($0 + batchSize, ids.count)])
        }
        return batches
    }
    
    func deleteAll(userID: String) async throws {
        let documents = try await fetchAll(userID: userID)
        if !documents.isEmpty {
            let documentBatches = createDocumentBatches(documents: documents, batchSize: 500)
            for batch in documentBatches {
                try Task.checkCancellation()
                let writeBatch = Firestore.firestore().batch()
                for document in batch {
                    let docRef = Firestore.firestore().collection(collectionPath).document(document.id)
                    writeBatch.deleteDocument(docRef)
                }
                try await writeBatch.commit()
            }
        }
    }
    
    // MARK: - Fetch Methods
    
    /// Fetches all documents from the Firestore collection path associated with this service.
    func fetchAll(userID: String, documentLimit: Int? = nil) async throws -> [Document] {
        do {
            return try await query(predicates: [], userID: userID, documentLimit: documentLimit)
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    /// Fetches a single document by its ID from Firestore.
    func fetch(id: String) async throws -> Document? {
        let reference = Firestore.firestore().collection(collectionPath)
        
        do {
            let snapshot = try await reference.document(id).getDocument()
            if snapshot.exists {
                return try snapshot.data(as: Document.self)
            } else {
                return nil
            }
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    func fetchDocuments(ids: [String]) async throws -> [Document] {
        var allDocuments: [Document] = []
        
        let idBatches = createIDBatches(ids: ids)

        for batch in idBatches {
            try Task.checkCancellation()
            let query = Firestore.firestore().collection(collectionPath).whereField(FieldPath.documentID(), in: batch)
            let snapshot = try await query.getDocuments()
            let documents = snapshot.documents.compactMap { try? $0.data(as: Document.self) }
            allDocuments.append(contentsOf: documents)
        }
        return sortedByDefault(allDocuments)
    }
    
    func getLastDocumentSnapshot(id: String?) async throws -> DocumentSnapshot? {
        guard let id else { return nil }
        let docRef = Firestore.firestore().collection(collectionPath).document(id)
        return try await docRef.getDocument()
    }
    
    func sortedByDefault(_ documents: [Document]) -> [Document] {
        if orderDirection == .ascending {
            return documents.sorted { $0[keyPath: orderByKeyPath] < $1[keyPath: orderByKeyPath] }
        } else {
            return documents.sorted { $0[keyPath: orderByKeyPath] > $1[keyPath: orderByKeyPath] }
        }
    }
    
    /// Fetches a random subset of documents from Firestore, with an optional ordering field.
    func fetchRandom(userID: String) async throws -> [Document] {
        do {
            let documents = try await fetchAll(userID: userID)
            let shuffledDocuments = documents.shuffled()
            return shuffledDocuments
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    /// Queries documents from Firestore based on the provided predicates.
    func query(predicates: [QueryPredicate], userID: String, documentLimit: Int? = nil) async throws -> [Document] {
        var allDocuments: [Document] = []
        var lastDocumentSnapshot: DocumentSnapshot? = nil
        var isLastBatch = false
        
        while !isLastBatch {
            try Task.checkCancellation()
            if let documentLimit, allDocuments.count >= documentLimit {
                break
            }
            
            let batchQuery = try await createQuery(predicates: predicates, userID: userID, lastDocument: lastDocumentSnapshot)
            let snapshot = try await batchQuery.getDocuments()
            if !snapshot.isEmpty {
                lastDocumentSnapshot = snapshot.documents.last
                let documents = snapshot.documents.compactMap { try? $0.data(as: Document.self) }
                allDocuments.append(contentsOf: documents)
                isLastBatch = snapshot.documents.count < 10
            } else {
                isLastBatch = true
            }
        }
        return allDocuments
    }
    
    /// Queries documents from Firestore based on two sets of predicates.
    func query(firstPredicates: [QueryPredicate], secondPredicates: [QueryPredicate], userID: String) async throws -> [Document] {
        do {
            let query1Documents = try await query(predicates: firstPredicates, userID: userID)
            let query2Documents = try await query(predicates: secondPredicates, userID: userID)
            let uniqueDocuments = Set(query1Documents + query2Documents)
            return Array(uniqueDocuments)
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    /// Retrieves the count of documents that matches the provided query predicates.
    func queryCount(predicates: [QueryPredicate], userID: String) async throws -> Int {
        let query: Query = try await createQuery(predicates: predicates, userID: userID)
        
        do {
            let snapshot = try await query.getDocuments()
            if !snapshot.isEmpty {
                return snapshot.count
            } else {
                return 0
            }
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    func queryPaginatedDocuments(predicates: [QueryPredicate], userID: String, lastDocument: DocumentSnapshot? = nil) async throws -> [Document] {
        let query = try await createQuery(predicates: predicates, userID: userID, lastDocument: lastDocument)
        let snapshot = try await query.getDocuments()
        if !snapshot.isEmpty {
            return snapshot.documents.compactMap { try? $0.data(as: Document.self) }
            
        } else {
            return []
        }
    }
    
    /// Creates a Firestore query based on the provided predicates.
    func createQuery(predicates: [QueryPredicate], userID: String, lastDocument: DocumentSnapshot? = nil) async throws -> Query {
        var query: Query = Firestore.firestore().collection(collectionPath)
        
        query = query.whereField("userID", isEqualTo: userID)
        
        for predicate in predicates {
            query = predicate.apply(to: query)
        }
        if !containsOrderByQueryPredicate(for: predicates) {
            query = defaultOrderQueryPredicate.apply(to: query)
        }
        
        if let lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        if !containsLimitToQueryPredicate(for: predicates) {
            query = query.limit(to: 10)
        }
        return query
    }
    
    func hasDocument(userID: String) async throws -> Bool {
        let query: Query = try await createQuery(predicates: [.limitTo(field: 1)], userID: userID)
        do {
            let snapshot = try await query.getDocuments()
            return snapshot.count == 1 ? true : false
        } catch {
            throw DatabaseError.fetchError
        }
    }
    
    private func containsOrderByQueryPredicate(for predicates: [QueryPredicate]) -> Bool {
        for predicate in predicates {
            switch predicate {
            case .orderBy(_, _):
                return true
            default:
                continue
            }
        }
        return false
    }
    
    private func containsLimitToQueryPredicate(for predicates: [QueryPredicate]) -> Bool {
        for predicate in predicates {
            switch predicate {
            case .limitTo(_):
                return true
            default:
                continue
            }
        }
        return false
    }
    
    func encodeToFirestore(document: Document) -> [String: Any] {
        var data: [String: Any] = [:]
        
        let mirror = Mirror(reflecting: document)
        
        for child in mirror.children {
            guard let propertyName = child.label else { continue }
        
            let value = child.value
            let convertedValue = convertToFirestoreValue(value: value)
            data[propertyName] = convertedValue
        }
        return data
    }
    
    func convertToFirestoreValue(value: Any) -> Any {
        if let optionalValue = value as? OptionalProtocol {
            return optionalValue.setOptionalValue()
        } else {
            if let themeValue = value as? Theme {
                return themeValue.rawValue
            } else if let diffultyLevelValue = value as? DifficultyLevel {
                return diffultyLevelValue.rawValue
            } else if let reviewMode = value as? ReviewMode {
                return reviewMode.rawValue
            } else {
                return value
            }
        }
    }
}

extension FirestoreService {
    enum OrderDirection {
        case ascending, descending
    }
}

protocol OptionalProtocol {
    func setOptionalValue() -> Any
}

extension Optional: OptionalProtocol {
    // Set optional data types to NSNull explicitly for Firestore
    func setOptionalValue() -> Any {
        switch self {
        case .none: return NSNull()
        case .some(let value):
            return value
        }
    }
}
