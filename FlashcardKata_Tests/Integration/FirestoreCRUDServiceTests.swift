//
//  FirestoreCRUDServiceTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import XCTest
import FirebaseFirestore

@MainActor
final class FirestoreCRUDServiceTests: XCTestCase {
    
    var firestore: Firestore!
    var testService: FirestoreCRUDService<Flashcard>!
    let testCollectionPath: String = FirestoreCollectionPathType.flashcard.path
    
    // MARK: - Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()
        firestore = Firestore.firestore()
        setupTestService()
    }
    
    private func setupTestService() {
        testService = FirestoreCRUDService<Flashcard>(
            collectionPathType: .custom(testCollectionPath)
        )
    }

    override func tearDown() async throws {
        try await clearCollection(testCollectionPath)
        firestore = nil
        testService = nil
        try await super.tearDown()
    }
    
    private func clearCollection(_ collectionPath: String) async throws {
        let collectionRef = firestore.collection(collectionPath)
        let snapshot = try await collectionRef.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }
    
    // MARK: - Test Methods
    func testCreateDocument_successfullyCreatesDocument() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let document = Flashcard.sampleFlashcard
        
        try await service.create(document)
        let fetchedSnapshot = try await firestore.collection(testCollectionPath).document(document.id).getDocument()
        let fetchedData = fetchedSnapshot.data()
        
        XCTAssertEqual(fetchedData?["id"] as? String, document.id)
        XCTAssertEqual(fetchedData?["frontText"] as? String, document.frontText)
    }
    
    func testUpdateDocument_successfullyUpdatesDocument() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        var document = Flashcard.sampleFlashcard
        
        try await service.create(document)
        let newDocumentFrontText = "Updated Flashcard Front Text"
        document.frontText = newDocumentFrontText
        try await service.updateDocument(document)
        
        let fetchedSnapshot = try await firestore.collection(testCollectionPath).document(document.id).getDocument()
        let fetchedData = fetchedSnapshot.data()
        XCTAssertEqual(fetchedData?["id"] as? String, document.id)
        XCTAssertEqual(fetchedData?["frontText"] as? String, newDocumentFrontText)
    }
    
    func testDeleteDocument_successfullyDeletesDocument() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let document = Flashcard.sampleFlashcard
        
        try await service.create(document)
        let preDeleteSnapshot = try await firestore.collection(testCollectionPath).document(document.id).getDocument()
        XCTAssertTrue(preDeleteSnapshot.exists)
        try await service.delete(id: document.id)
        let postDeleteSnapshot = try await firestore.collection(testCollectionPath).document(document.id).getDocument()
        XCTAssertFalse(postDeleteSnapshot.exists)
    }
}
