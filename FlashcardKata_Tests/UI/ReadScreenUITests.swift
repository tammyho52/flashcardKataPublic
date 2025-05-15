//
//  ReadScreenUITests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import XCTest

@MainActor
final class ReadScreenUITests: XCTestCase {
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
    
    private func navigateToReadTab() async throws {
        let readTabLabel = app.buttons["readTabButton"]
        XCTAssertTrue(readTabLabel.waitForExistence(timeout: 1), "Read tab should exist")
        
        readTabLabel.tap()
    }
    
    func testNavigateToReadTab() async throws {
        try await navigateToReadTab()
        
        let readTabScreen = app.scrollViews["readTabScreen"]
        XCTAssertTrue(readTabScreen.waitForExistence(timeout: 5), "Read tab screen should exist")
    }
    
    private func fetchVisibleFlashcard(for flashcards: [XCUIElement]) -> XCUIElement? {
        flashcards.first { $0.frame.intersects(app.windows.firstMatch.frame) }
    }
    
    func testSwitchFlashcardOnSwipe() async throws {
        try await navigateToReadTab()
        
        // Check for flashcard list
        try await Task.sleep(for: .seconds(5)) // Wait for flashcards to load
        print(app.debugDescription)
        let flashcards = app.otherElements.matching(identifier: "readFlashcard").allElementsBoundByIndex
        XCTAssertTrue(flashcards.count > 0, "Flashcards should exist")
        
        // Check for first card
        guard let firstCard = fetchVisibleFlashcard(for: flashcards) else {
            XCTFail("First card should exist")
            return
        }
        XCTAssertTrue(firstCard.waitForExistence(timeout: 2), "First card should exist")
        
        let allFlashcardFrontText = app.buttons.matching(identifier: "flashcardFrontText").allElementsBoundByIndex
        guard let firstCardFlashcardFrontText = fetchVisibleFlashcard(for: allFlashcardFrontText) else {
            XCTFail("First card front text should exist")
            return
        }
        
        // Swipe to next card and check for second card
        firstCard.swipeLeft()
        guard let secondCard = fetchVisibleFlashcard(for: flashcards) else {
            XCTFail("Second card should exist")
            return
        }
        XCTAssertTrue(secondCard.waitForExistence(timeout: 2), "Second card should exist")
        
        guard let secondCardFlashcardFrontText = fetchVisibleFlashcard(for: allFlashcardFrontText) else {
            XCTFail("Second card front text should exist")
            return
        }
        XCTAssertNotEqual(firstCardFlashcardFrontText.label, secondCardFlashcardFrontText.label, "First card label should not equal second card label")
        
        // Swipe to prior card and check for first card
        secondCard.swipeRight()
        
        guard let firstCardAgain = fetchVisibleFlashcard(for: flashcards) else {
            XCTFail("First card should exist")
            return
        }
        XCTAssertTrue(firstCardAgain.waitForExistence(timeout: 2), "First card should exist")
    }
    
    func testFlashcardFlipsOnTap() async throws {
        try await navigateToReadTab()
        
        // Check for flashcard card view
        let currentFlashcard = app.otherElements.matching(identifier: "readFlashcard").firstMatch
        XCTAssertTrue(currentFlashcard.waitForExistence(timeout: 2), "Current card should exist")
        
        // Check for front text
        let frontText = app.buttons.matching(identifier: "flashcardFrontText").firstMatch
        let frontTextLabel = frontText.label
        XCTAssertTrue(frontText.waitForExistence(timeout: 2), "Front text should exist")
        
        // Tap to flip card and check for back text
        currentFlashcard.tap()
        XCTAssertTrue(currentFlashcard.waitForExistence(timeout: 2), "Current card should exist")
        let backText = app.buttons.matching(identifier: "flashcardBackText").firstMatch
        let backTextLabel = backText.label
        XCTAssertTrue(backText.waitForExistence(timeout: 2), "Back text should exist")
        XCTAssertFalse(frontText.exists)
        XCTAssertNotEqual(frontTextLabel, backTextLabel, "Front text should not equal back text")
        
        // Tap again to flip back and check for front text
        currentFlashcard.tap()
        let flippedFrontText = app.buttons.matching(identifier: "flashcardFrontText").firstMatch
        let flippedFrontTextLabel = flippedFrontText.label
        XCTAssertEqual(flippedFrontTextLabel, frontTextLabel)
    }
    
    func testChangeFlashcardLayoutOnTap() async throws {
        try await navigateToReadTab()
        
        let flashcardLayoutButton = app.otherElements["readFlashcardLayoutButton"]
        XCTAssertTrue(flashcardLayoutButton.waitForExistence(timeout: 2), "Flashcard layout button should exist")
        
        // Check for front only flashcard layout
        print(app.debugDescription)
        let frontText = app.buttons.matching(identifier: "flashcardFrontText").firstMatch
        let frontTextLabel = frontText.label
        XCTAssertTrue(frontText.waitForExistence(timeout: 2), "Front text should exist")
        
        let backText = app.buttons.matching(identifier: "flashcardBackText").firstMatch
        XCTAssertFalse(backText.exists, "Back text should not exist")
        
        // Check for front and back flashcard layout
        flashcardLayoutButton.tap()
        let combinedLayoutFrontText = app.buttons.matching(identifier: "flashcardFrontText").firstMatch
        let combinedFrontTextLabel = frontText.label
        XCTAssertTrue(combinedLayoutFrontText.waitForExistence(timeout: 2), "Front and back layout should exist")
        XCTAssertEqual(combinedFrontTextLabel, frontTextLabel)
        
        let combinedLayoutBackText = app.buttons.matching(identifier: "flashcardBackText").firstMatch
        let combinedBackTextLabel = backText.label
        XCTAssertTrue(combinedLayoutBackText.waitForExistence(timeout: 2), "Back text should exist")
        XCTAssertNotEqual(combinedBackTextLabel, combinedFrontTextLabel)
        
        // Check for front only flashcard layout again
        flashcardLayoutButton.tap()
        let flippedFrontText = app.buttons.matching(identifier: "flashcardFrontText").firstMatch
        let finalFrontTextLabel = frontText.label
        XCTAssertTrue(flippedFrontText.waitForExistence(timeout: 2), "Front text should exist")
        XCTAssertEqual(finalFrontTextLabel, frontTextLabel)
        
        let flippedBackText = app.buttons.matching(identifier: "flashcardBackText").firstMatch
        XCTAssertFalse(flippedBackText.exists, "Back text should not exist")
    }
}
