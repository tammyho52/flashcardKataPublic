//
//  FirestoreServiceTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import XCTest
import FirebaseFirestore

@MainActor
final class FirestoreServiceTests: XCTestCase {
    
    var firestore: Firestore!
    var testService: FirestoreService<Flashcard, Date>!
    let testCollectionPath: String = FirestoreCollectionPathType.flashcard.path
    
    // MARK: - Setup and Teardown
    override func setUp() async throws {
        try await super.setUp()
        firestore = Firestore.firestore()
        setupTestService()
    }
    
    private func setupTestService() {
        testService = FirestoreService<Flashcard, Date>(
            firestore: firestore,
            collectionPathType: .custom(testCollectionPath),
            orderByKeyPath: \Flashcard.updatedDate
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
    func testDeleteAll_successfullyDeletesAllDocuments() async throws {
        guard let service = testService else {
            XCTFail("Service not initialized")
            return
        }
        let documents = Flashcard.sampleFlashcardArray
        
        for document in documents {
            try await service.create(document)
        }
        let preDeleteSnapshot = try await firestore.collection(testCollectionPath).getDocuments()
        XCTAssertTrue(preDeleteSnapshot.documents.count == documents.count)
        
        try await service.deleteAll(userID: "testUserID")
        let snapshot = try await firestore.collection(testCollectionPath).getDocuments()
        XCTAssertTrue(snapshot.documents.isEmpty)
    }
    
    func testHandleFirestoreNSError_permissionDenied_returnsPermissionError() {
        let error = NSError(
            domain: FirestoreErrorDomain,
            code: FirestoreErrorCode.permissionDenied.rawValue,
            userInfo: nil
        )
        let appError = testService.handleFirestoreNSError(error)
        XCTAssertEqual(appError, .permissionError)
    }
    
    func testHandleFirestoreNSError_alreadyExists_returnsValidationError() {
        let error = NSError(
            domain: FirestoreErrorDomain,
            code: FirestoreErrorCode.alreadyExists.rawValue,
            userInfo: nil
        )
        let appError = testService.handleFirestoreNSError(error)
        XCTAssertEqual(appError, .validationError("The data already exists."))
    }
    
    func testHandleFirestoreNSError_unknownError_returnsSystemError() {
        let error = NSError(
            domain: "OtherDomain",
            code: -1,
            userInfo: nil
        )
        let appError = testService.handleFirestoreNSError(error)
        XCTAssertEqual(appError, .systemError)
    }
}
