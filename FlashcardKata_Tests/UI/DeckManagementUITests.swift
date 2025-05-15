//
//  DeckManagementUITests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import XCTest

@MainActor
final class DeckManagementUITests: XCTestCase {
    
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
    
    func testHomeScreenAppeared() async throws {
        let homeScreenTabViewLabel = app.otherElements["tabView"]
        XCTAssertTrue(homeScreenTabViewLabel.waitForExistence(timeout: 5), "Home screen tab view should exist")
    }
    
    func testDeckDisclosureButtonToggle() async throws {
        let deck = Deck.sampleDeckArray[1]
        let deckDisclosureButton = app.buttons["deckDisclosureButton_\(deck.id)"]
        XCTAssertTrue(deckDisclosureButton.waitForExistence(timeout: 5), "Deck disclosure button should exist after sign in")
        
        let subDeckButton = app.buttons["subdeckButton_\(deck.subdeckIDs[0])"]
        XCTAssertFalse(subDeckButton.waitForExistence(timeout: 1), "Subdeck should not be expanded")
        
        deckDisclosureButton.tap()
        XCTAssertTrue(subDeckButton.waitForExistence(timeout: 1), "Subdeck should be expanded")
    }
    
    func testEmptyFlashcardListAppearsAfterDeckButtonTap() async throws {
        let deck = Deck.sampleDeckArray[0]
        // Check for deck button
        let deckButton = app.buttons["deckButton_\(deck.id)"]
        XCTAssertTrue(deckButton.waitForExistence(timeout: 10), "Deck button should exist after sign in")
        deckButton.tap()
        
        // Check for empty flashcard list screen
        let emptyFlashcardListScreen = app.buttons["flashcardListScreenEmpty"]
        XCTAssertTrue(emptyFlashcardListScreen.waitForExistence(timeout: 5), "Empty flashcard list screen should exist after tapping deck button")
    }
    
    func testLoadedFlashcardListAppearsAfterDeckButtonTap() async throws {
        let deck = Deck.sampleDeckArray[1]
        // Check for deck button
        let deckButton = app.buttons["deckButton_\(deck.id)"]
        XCTAssertTrue(deckButton.waitForExistence(timeout: 10), "Deck button should exist after sign in")
        deckButton.tap()
        
        // Check for flashcard list view
        let flashcardListView = app.collectionViews["flashcardListScreenWithData"]
        XCTAssertTrue(flashcardListView.waitForExistence(timeout: 5), "Flashcard list view should exist after tapping deck button")
        
        // Check for loaded flashcard list screen
        for flashcardID in deck.flashcardIDs {
            let loadedFlashcard = app.buttons["flashcardCoverView_\(flashcardID)"]
            XCTAssertTrue(loadedFlashcard.waitForExistence(timeout: 1), "Flashcard button should exist after tapping deck button")
        }
    }
    
    func testAddDeckButtonTap() async throws {
        let addDeckButton = app.buttons["addDeckButton"]
        XCTAssertTrue(addDeckButton.waitForExistence(timeout: 5), "Add deck button should exist after sign in")
        
        addDeckButton.tap()
        
        let addDeckScreen = app.scrollViews["addDeckScreen"]
        XCTAssertTrue(addDeckScreen.waitForExistence(timeout: 5), "Add deck screen should exist after tapping add deck button")
    }
    
    func testShowModifyDeckButtons() async throws {
        let showModifyDeckButton = app.buttons["showModifyDeckButton"]
        XCTAssertTrue(showModifyDeckButton.waitForExistence(timeout: 5), "Show modify deck button should exist after sign in")
        
        showModifyDeckButton.tap()
        let deck = Deck.sampleDeckArray[1]
        let editDeckButton = app.buttons["editDeckButton_\(deck.id)"]
        let deleteDeckButton = app.buttons["deleteDeckButton_\(deck.id)"]
        XCTAssertTrue(editDeckButton.waitForExistence(timeout: 1), "Edit deck button should exist after tapping show modify deck button")
        XCTAssertTrue(deleteDeckButton.waitForExistence(timeout: 1), "Delete deck button should exist after tapping show modify deck button")
    }
    
    func testEditDeckButtonTap() async throws {
        let showModifyDeckButton = app.buttons["showModifyDeckButton"]
        showModifyDeckButton.tap()
        
        let deck = Deck.sampleDeckArray[1]
        let editDeckButton = app.buttons["editDeckButton_\(deck.id)"]
        editDeckButton.tap()
        XCTAssertTrue(app.scrollViews["editDeckScreen"].waitForExistence(timeout: 1), "Edit deck screen should exist after tapping edit deck button")
        
        let deckNameTextField = app.textFields["deckNameTextField"]
        XCTAssertTrue(deckNameTextField.exists)
        XCTAssertEqual(deckNameTextField.value as? String, deck.name)
    }
    
    func testDeleteDeckButtonTap() async throws {
        let showModifyDeckButton = app.buttons["showModifyDeckButton"]
        showModifyDeckButton.tap()
        
        let deck = Deck.sampleDeckArray[1]
        let deleteDeckButton = app.buttons["deleteDeckButton_\(deck.id)"]
        deleteDeckButton.tap()
        
        let alert = app.alerts["Delete Deck"]
        XCTAssertTrue(alert.waitForExistence(timeout: 1), "Delete deck alert should exist after tapping delete deck button")
        
        let alertMessage = alert.staticTexts["Are you sure you want to delete \(deck.name) \(deck.subdeckCount > 0 ? "and all associated subdecks" : "")? This action cannot be undone."]
        XCTAssertTrue(alertMessage.exists)
    }
}
