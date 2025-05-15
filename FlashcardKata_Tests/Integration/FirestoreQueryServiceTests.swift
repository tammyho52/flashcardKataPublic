//
//  FirestoreQueryServiceTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import XCTest
import FirebaseFirestore

@MainActor
final class FirestoreQueryServiceTests: XCTestCase {
    
    var firestore: Firestore!
    var testService: FirestoreQueryService<Flashcard, Date>!
    var crudService: FirestoreCRUDService<Flashcard>!
    let testCollectionPath: String = FirestoreCollectionPathType.flashcard.path

    // MARK: - Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()
        firestore = Firestore.firestore()
        setupTestService()
    }
    
    private func setupTestService() {
        testService = FirestoreQueryService<Flashcard, Date>(
            firestore: firestore,
            collectionPathType: .custom(testCollectionPath),
            orderByKeyPath: \Flashcard.updatedDate
        )
        crudService = FirestoreCRUDService<Flashcard>(
            firestore: firestore,
            collectionPathType: .custom(testCollectionPath)
        )
    }

    override func tearDown() async throws {
        try await clearCollection(testCollectionPath)
        try await waitForEmptyCollection(testCollectionPath)
        firestore = nil
        testService = nil
        try await super.tearDown()
    }
    
    private func waitForEmptyCollection(_ collectionPath: String) async throws {
        let collectionRef = firestore.collection(collectionPath)
        var snapshot: QuerySnapshot
        repeat {
            snapshot = try await collectionRef.getDocuments()
            try await Task.sleep(for: .seconds(1))
        } while !snapshot.documents.isEmpty
    }
    
    private func clearCollection(_ collectionPath: String) async throws {
        let collectionRef = firestore.collection(collectionPath)
        let snapshot = try await collectionRef.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    // MARK: - Test Methods
    func testFetchAll_successfullyFetchesAllDocuments() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let documents = Flashcard.sampleFlashcardArray
        
        for document in documents {
            try await crudService.create(document)
        }
        let fetchedDocuments = try await service.fetchAll(userID: "testUserID")
        XCTAssertEqual(fetchedDocuments.count, documents.count)
    }
    
    func testFetchAllWithLimit_successfullyFetchesLimitedDocuments() async throws {
        guard let service = testService else {
            XCTFail("Service not initalized")
            return
        }
        let documents = Flashcard.sampleFlashcardArray
        
        for document in documents {
            try await crudService.create(document)
        }
        let fetchedDocuments = try await service.fetchAll(userID: "testUserID", documentLimit: 2)
        XCTAssertEqual(fetchedDocuments.count, 2)
    }
    
    func testFetch_successfullyFetchDocument() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let document = Flashcard.sampleFlashcard
        try await crudService.create(document)
        let fetchedDocument = try await service.fetch(id: document.id)
        XCTAssertEqual(fetchedDocument?.id, document.id)
    }
    
    func testFetchDocuments_successfullyFetchDocuments() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let documents = Flashcard.sampleFlashcardArray[0..<4]
        for document in documents {
            try await crudService.create(document)
        }
        let ids = documents.map { $0.id }
        let fetchedDocuments = try await service.fetchDocuments(ids: ids)
        XCTAssertEqual(fetchedDocuments.count, documents.count)
    }
    
    func testQuery_successfullyFetchesDocuments() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let documents = Flashcard.sampleFlashcardArray.prefix(5)
        for document in documents {
            try await crudService.create(document)
        }
        let fetchedDocuments = try await service.query(
            predicates: [
                .isIn(field: "id", values: Flashcard.sampleFlashcardArray.prefix(2).map { $0.id })
            ],
            userID: "testUserID"
        )
        XCTAssertEqual(fetchedDocuments.count, 2)
    }
    
    func testQueryPaginatedDocuments_successfullyFetchesPaginatedDocuments() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        // Match the sorting order with the orderByKeyPath
        let documents = Flashcard.sampleFlashcardArray.prefix(4).sorted(by: { $0.updatedDate > $1.updatedDate })
        for document in documents {
            try await crudService.create(document)
        }
        let preQueryFetchedDocuments = try await service.fetchAll(userID: "testUserID")
        XCTAssertEqual(preQueryFetchedDocuments.count, 4)
        
        let fetchedDocuments = try await service.queryPaginatedDocuments(
            predicates: [],
            userID: "testUserID",
            lastDocumentID: preQueryFetchedDocuments[1].id // Assumes this is the last document ID
        )
        try await Task.sleep(for: .seconds(2))
        XCTAssertEqual(fetchedDocuments.count, 2)
    }
    
    func testHasDocument_successfullyChecksForDocument() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let document = Flashcard.sampleFlashcardArray[5]
        
        try await crudService.create(document)
        if let documentUserID = document.userID {
            let hasDocument = await service.hasDocument(userID: documentUserID)
            XCTAssertTrue(hasDocument)
        } else {
            XCTFail("Document not found")
        }
    }
    
    func testHasDocumentWithPredicates_successfullyChecksForDocument() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let document = Flashcard.sampleFlashcardArray[4]
        
        try await crudService.create(document)
        if let documentUserID = document.userID {
            let hasDocument = try await service.hasDocument(
                predicates: [
                    .isIn(field: "id", values: [document.id])
                ],
                userID: documentUserID
            )
            XCTAssertTrue(hasDocument)
        } else {
            XCTFail("Document not found")
        }
    }
}
