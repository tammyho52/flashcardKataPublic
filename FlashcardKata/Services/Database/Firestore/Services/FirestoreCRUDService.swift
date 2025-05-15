//
//  FirestoreCRUDService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This structure abstracts interactions with Firestore for CRUD operations, providing a scalable and reusable solution for managing Firestore documents.

import Foundation
import FirebaseFirestore

/// A generic service for performing CRUD operations on Firestore documents.
struct FirestoreCRUDService<Document: Firestorable> {
    // MARK: - Properties
    let firestore: Firestore
    let collectionPath: String
    
    // MARK: - Initializer
    init(
        firestore: Firestore = Firestore.firestore(),
        collectionPathType: FirestoreCollectionPathType
    ) {
        self.firestore = firestore
        self.collectionPath = collectionPathType.path
    }
    
    /// Creates a new document in Firestore.
    /// - Parameter document: The document to be created.
    func create(_ document: Document) async throws {
        let reference = firestore.collection(collectionPath).document(document.id)
        let documentData = encodeToFirestore(document: document)
        try await reference.setData(documentData)
    }

    /// Updates an existing document in Firestore.
    /// - Parameter document: The document to be updated.
    func updateDocument(_ document: Document) async throws {
        let reference = firestore.collection(collectionPath)
        let documentData = encodeToFirestore(document: document)
        try await reference.document(document.id).setData(documentData, merge: true)
    }
    
    /// Updates specific fields of a document in Firestore.
    /// - Parameters:
    ///   - id: The ID of the document to be updated.
    ///   - updates: The updates to be applied to the document.
    func updateDocumentFields(id: String, updates: [DatabaseUpdate]) async throws {
        let reference = firestore.collection(collectionPath)
        var updateData: [String: Any] = [:]

        for update in updates {
            let field = update.field

            switch update.operation {
            case .add(let values):
                updateData[field] = FieldValue.arrayUnion(convertValuesToFirestoreValues(values))
            case .remove(let values):
                updateData[field] = FieldValue.arrayRemove(convertValuesToFirestoreValues(values))
            case .update(let value):
                updateData[field] = Document.convertToFirestoreValue(value: value)
            case .increment(let incrementValue):
                updateData[field] = FieldValue.increment(Int64(incrementValue))
            }
            try Task.checkCancellation()
        }
        try await reference.document(id).updateData(updateData)
    }
    
    /// Deletes a document from Firestore.
    /// - Parameter id: The ID of the document to be deleted.
    func delete(id: String) async throws {
        let reference = firestore.collection(collectionPath).document(id)
        try await reference.delete()
    }
    
    // MARK: - Firestore Conversion Methods
    /// Encodes a document to a dictionary format suitable for Firestore.
    /// - Parameter document: The document to be encoded.
    /// - Returns: A dictionary representation of the document.
    private func encodeToFirestore(document: Document) -> [String: Any] {
        var data: [String: Any] = [:]

        let mirror = Mirror(reflecting: document)

        for child in mirror.children {
            guard let propertyName = child.label else { continue }

            let value = child.value
            let convertedValue = Document.convertToFirestoreValue(value: value)
            data[propertyName] = convertedValue
        }
        return data
    }
    
    /// Converts an array of values to Firestore-compatible values.
    /// - Parameter values: The array of values to be converted.
    /// - Returns: An array of Firestore-compatible values.
    private func convertValuesToFirestoreValues(_ values: [Any]) -> [Any] {
        return values.map { Document.convertToFirestoreValue(value: $0) }
    }
}
