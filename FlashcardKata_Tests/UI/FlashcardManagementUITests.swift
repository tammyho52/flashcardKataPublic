//
//  FlashcardManagementUITests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import XCTest

@MainActor
final class FlashcardManagementUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() async throws {
        try await super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
    }

    override func tearDown() async throws {
        app.terminate()
        app = nil
        try await super.tearDown()
    }
    
    private func navigateToFlashcardListScreen() async throws {
        let homeScreenTabViewLabel = app.otherElements["tabView"]
        XCTAssertTrue(homeScreenTabViewLabel.waitForExistence(timeout: 5), "Home screen tab view should exist")
        
        let deck = Deck.sampleDeckArray[1]
        let deckButton = app.buttons["deckButton_\(deck.id)"]
        deckButton.tap()
    }
    
    func testNavigateToFlashcardListScreen() async throws {
        try await navigateToFlashcardListScreen()
        
        let flashcardListScreen = app.collectionViews["flashcardListScreenWithData"]
        XCTAssertTrue(flashcardListScreen.exists)
    }
    
    func testAddFlashcardButtonTap() async throws {
        try await navigateToFlashcardListScreen()
        
        let addFlashcardButton = app.buttons["addFlashcardButton"]
        XCTAssertTrue(addFlashcardButton.exists)
        
        addFlashcardButton.tap()
        let addFlashcardScreen = app.collectionViews["addFlashcardScreen"]
        XCTAssertTrue(addFlashcardScreen.waitForExistence(timeout: 3), "Add flashcard screen should exist after tapping add flashcard button")
    }
    
    func testShowModifyFlashcardButtons() async throws {
        try await navigateToFlashcardListScreen()
        
        let showModifyFlashcardButton = app.buttons["showModifyFlashcardButton"]
        XCTAssertTrue(showModifyFlashcardButton.waitForExistence(timeout: 5), "Show modify flashcard button should exist")
        
        showModifyFlashcardButton.tap()
        let flashcard = Flashcard.sampleFlashcard2
        let editFlashcardButton = app.buttons["editFlashcardButton_\(flashcard.id)"]
        let deleteFlashcardButton = app.buttons["deleteFlashcardButton_\(flashcard.id)"]
        XCTAssertTrue(editFlashcardButton.waitForExistence(timeout: 1), "Edit flashcard button should exist after tapping show modify flashcard button")
        XCTAssertTrue(deleteFlashcardButton.waitForExistence(timeout: 1), "Delete flashcard button should exist after tapping show modify flashcard button")
    }
    
    func testEditFlashcardButtonTap() async throws {
        try await navigateToFlashcardListScreen()
        
        let showModifyFlashcardButton = app.buttons["showModifyFlashcardButton"]
        showModifyFlashcardButton.tap()
        
        let flashcard = Flashcard.sampleFlashcard2
        let editFlashcardButton = app.buttons["editFlashcardButton_\(flashcard.id)"]
        editFlashcardButton.tap()
        XCTAssertTrue(app.collectionViews["editFlashcardScreen"].waitForExistence(timeout: 1), "Edit flashcard screen should exist after tapping edit flashcard button")
        
        let flashcardFrontTextField = app.textViews["flashcardFrontTextField"]
        XCTAssertTrue(flashcardFrontTextField.exists)
        XCTAssertEqual(flashcardFrontTextField.value as? String, flashcard.frontText)
    }
    
    func testDeleteFlashcardButtonTap() async throws {
        try await navigateToFlashcardListScreen()
        
        let showModifyFlashcardButton = app.buttons["showModifyFlashcardButton"]
        showModifyFlashcardButton.tap()
        
        let flashcard = Flashcard.sampleFlashcard2
        let deleteFlashcardButton = app.buttons["deleteFlashcardButton_\(flashcard.id)"]
        deleteFlashcardButton.tap()
        
        let alert = app.alerts["Delete Flashcard"]
        XCTAssertTrue(alert.waitForExistence(timeout: 1), "Delete flashcard alert should exist after tapping delete flashcard button")
        
        let alertMessage = alert.staticTexts["Are you sure you want to delete this flashcard? This action cannot be undone."]
        XCTAssertTrue(alertMessage.exists)
    }
}
