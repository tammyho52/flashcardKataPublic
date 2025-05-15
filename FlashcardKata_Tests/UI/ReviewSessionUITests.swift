//
//  ReviewSessionUITests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import XCTest

@MainActor
final class ReviewSessionUITests: XCTestCase {
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
    
    private func navigateToReviewTab() async throws {
        let reviewTabLabel = app.buttons["kataTabButton"]
        XCTAssertTrue(reviewTabLabel.waitForExistence(timeout: 1), "Review tab should exist")
        
        reviewTabLabel.tap()
    }
    
    func testNavigateToReviewTab() async throws {
        try await navigateToReviewTab()
        
        let reviewTabScreen = app.collectionViews["reviewTabScreen"]
        XCTAssertTrue(reviewTabScreen.waitForExistence(timeout: 5), "Review tab screen should exist")
    }
    
    private func launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: String) async throws {
        try await navigateToReviewTab()
        
        // Locate and check for Practice Mode review session button
        let practiceModeReviewSessionButton = app.buttons["\(reviewModeButtonName)"]
        XCTAssertTrue(practiceModeReviewSessionButton.waitForExistence(timeout: 1), "Practice mode review session button should exist")
        
        // Navigate to the review session settings screen
        practiceModeReviewSessionButton.tap()
        let reviewSessionSettingsScreen = app.collectionViews["reviewSessionSettingsScreen"]
        XCTAssertTrue(reviewSessionSettingsScreen.waitForExistence(timeout: 1), "Review session settings screen should exist")
        
        // Locate and check for the start review session button
        let startReviewSessionButton = app.buttons["startReviewSessionButton"]
        XCTAssertTrue(startReviewSessionButton.waitForExistence(timeout: 1), "Start review session button should exist")
        
        // Tap to start the review session and verify the first flashcard appears (based on flashcard index)
        startReviewSessionButton.tap()
    }
    
    func testStartReviewSessionFlowWithDefaultCardSelection() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        let reviewSessionScreen = app.otherElements["reviewSessionFlashcardView_0"]
        XCTAssertTrue(reviewSessionScreen.waitForExistence(timeout: 3), "Review session screen should exist")
    }
    
    func testFlashcardFlipsOnTap() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        // Verify the first flashcard appears with front text showing
        let flashcardFrontText = app.buttons["flashcardFrontText"]
        XCTAssertTrue(flashcardFrontText.waitForExistence(timeout: 1), "Flashcard front text should exist")
        
        // Tap to flip the flashcard and verify the back text appears
        let flashcardView = app.otherElements["reviewSessionFlashcardView_0"]
        flashcardView.tap()
        let flashcardBackText = app.buttons["flashcardBackText"]
        XCTAssertTrue(flashcardBackText.waitForExistence(timeout: 1), "Flashcard back text should exist")
        
        // Tap again to flip back to the front text
        flashcardView.tap()
        let flippedFlashcardFrontText = app.buttons["flashcardFrontText"]
        XCTAssertTrue(flippedFlashcardFrontText.waitForExistence(timeout: 1), "Flipped flashcard front text should exist")
        XCTAssertEqual(flashcardFrontText.value as? String, flippedFlashcardFrontText.value as? String, "Flipped flashcard front text should match original front text")
    }
    
    private func testProgressCardCount(expectedCount: Int, totalCount: Int) {
        let cardCountLabel = app.staticTexts["reviewCardCounter"]
        XCTAssertTrue(cardCountLabel.waitForExistence(timeout: 1), "Card count label should exist")
        XCTAssertEqual(cardCountLabel.label, "\(expectedCount) / \(totalCount)", "Card count label should show expected text")
    }
    
    func testExpectedProgressBarValues_startingIndex() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        // Verify the card count label
        let expectedCount = 0 // First Index
        let totalCount = Flashcard.sampleFlashcardArray.count
        testProgressCardCount(expectedCount: expectedCount, totalCount: totalCount)
        
        // Verify the progress bar
        let reviewProgressLabel = app.progressIndicators["reviewProgressLabel"]
        XCTAssertTrue(reviewProgressLabel.waitForExistence(timeout: 1), "Review progress value should exist")
        XCTAssertEqual(reviewProgressLabel.value as? String, "0%", "Review progress value should show expected")
    }
    
    func testBaseReviewSessionComponents() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        let correctScore = app.staticTexts["correctScore"]
        XCTAssertTrue(correctScore.waitForExistence(timeout: 1), "Correct score button should exist")
        XCTAssertEqual(correctScore.label, "0")
        
        let incorrectScore = app.staticTexts["incorrectScore"]
        XCTAssertTrue(incorrectScore.waitForExistence(timeout: 1), "Incorrect score button should exist")
        XCTAssertEqual(incorrectScore.label, "0")
    }
    
    func testPracticeReviewSessionComponents() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        let practiceText = app.staticTexts["practiceText"]
        XCTAssertTrue(practiceText.waitForExistence(timeout: 1), "Practice text should exist")
    }
    
    func testTargetReviewSessionComponents() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "TargetReviewSessionButton")
        
        let targetText = app.staticTexts["targetText"]
        XCTAssertTrue(targetText.waitForExistence(timeout: 1), "Target text should exist")
    }
    
    func testTimedReviewSessionComponents() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "TimedReviewSessionButton")
        
        let timerText = app.staticTexts["timerText"]
        XCTAssertTrue(timerText.waitForExistence(timeout: 1), "Timer text should exist")
    }
    
    func testStreakReviewSessionComponents() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "StreakReviewSessionButton")
        
        let streakText = app.staticTexts["streakCountText"]
        XCTAssertTrue(streakText.waitForExistence(timeout: 1), "Streak count text should exist")
    }
    
    private func tapButton(_ identifier: String, timeout: TimeInterval = 1) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: timeout), "\(identifier) button should exist")
        button.tap()
    }
    
    func testStartReviewSessionFlowWithCustomOneFlashcardSelection() async throws {
        try await navigateToReviewTab()
        
        // Locate and check for Practice Mode review session button
        tapButton("PracticeReviewSessionButton")
        
        // Navigate to the review session settings screen
        let reviewSessionSettingsScreen = app.collectionViews["reviewSessionSettingsScreen"]
        XCTAssertTrue(reviewSessionSettingsScreen.waitForExistence(timeout: 1), "Review session settings screen should exist")
        
        // Tap to navigate to the custom deck selection screen
        tapButton("customCardSelectionButton")
        let selectReviewDecksView = app.collectionViews["selectReviewDecksView"]
        XCTAssertTrue(selectReviewDecksView.waitForExistence(timeout: 1), "Select review decks view should exist")
        
        // Deselect all decks
        tapButton("selectAllButton")
        
        // Select a specific deck
        tapButton("subItemSelectionButton_\(Deck.sampleSubdeckArray[0].id)")
        
        // Tap to navigate to the flashcard selection screen
        tapButton("toolbarNextButton")
        
        let flashcardSelectionScreen = app.collectionViews["selectReviewFlashcardsView"]
        XCTAssertTrue(flashcardSelectionScreen.waitForExistence(timeout: 1), "Flashcard selection screen should exist")
        
        // Deselect all flashcards
        tapButton("selectAllButton")
        
        // Select a specific flashcard
        tapButton("subItemSelectionButton_\(Flashcard.sampleFlashcardArray[0].id)")
        tapButton("toolbarDoneButton")
        
        // Tap to start the review session and verify the first flashcard appears (based on flashcard index)
        tapButton("startReviewSessionButton")
        let reviewSessionScreen = app.otherElements["reviewSessionFlashcardView_0"]
        XCTAssertTrue(reviewSessionScreen.waitForExistence(timeout: 1), "Review session screen should exist")
        
        // Verify the card count label to load one flashcard
        testProgressCardCount(expectedCount: 0, totalCount: 1)
    }
    
    func testReviewSessionTransitionsOnIncorrectSwipe() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        var flashcardIndex = 0
        let flashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        
        // Swipe left to indicate an incorrect answer
        flashcardView.swipeLeft()
        let incorrectScoreView = app.staticTexts["incorrectScoreTransitionScreen"]
        XCTAssertTrue(incorrectScoreView.exists, "Incorrect score transition screen should exist")
        
        // Check for the next flashcard
        flashcardIndex += 1
        let nextFlashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        XCTAssertTrue(nextFlashcardView.waitForExistence(timeout: 3), "Next flashcard view should exist")
    }
    
    func testReviewSessionTransitionsOnCorrectSwipe() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        var flashcardIndex = 0
        let flashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        
        // Swipe right to indicate a correct answer
        flashcardView.swipeRight()
        let incorrectScoreView = app.staticTexts["correctScoreTransitionScreen"]
        XCTAssertTrue(incorrectScoreView.exists, "Correct score transition screen should exist")
        
        // Check for the next flashcard
        flashcardIndex += 1
        let nextFlashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        XCTAssertTrue(nextFlashcardView.waitForExistence(timeout: 3), "Next flashcard view should exist")
    }
    
    func testReviewSessionScoreChangesOnSwipe() async throws {
        try await launchReviewSessionWithDefaultCardSelection(reviewModeButtonName: "PracticeReviewSessionButton")
        
        var flashcardIndex = 0
        let firstFlashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        XCTAssertTrue(firstFlashcardView.waitForExistence(timeout: 1), "Flashcard view should exist")
        
        // Check initial scores
        let correctScore = app.staticTexts["correctScore"]
        let incorrectScore = app.staticTexts["incorrectScore"]
        XCTAssertEqual(correctScore.label, "0")
        XCTAssertEqual(incorrectScore.label, "0")
        
        // Swipe left to indicate an incorrect answer
        firstFlashcardView.swipeLeft()
        XCTAssertEqual(correctScore.label, "0")
        XCTAssertEqual(incorrectScore.label, "1")
        
        flashcardIndex += 1
        print(app.debugDescription)
        let secondFlashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        XCTAssertTrue(secondFlashcardView.waitForExistence(timeout: 3), "Flashcard view should exist")
        
        // Swipe right to indicate a correct answer
        secondFlashcardView.swipeRight()
        XCTAssertEqual(correctScore.label, "1")
        XCTAssertEqual(incorrectScore.label, "1")
        
        flashcardIndex += 1
        let thirdFlashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        XCTAssertTrue(thirdFlashcardView.waitForExistence(timeout: 3), "Flashcard view should exist")
    }
    
    func testReviewSessionCompletion() async throws {
        try await testStartReviewSessionFlowWithCustomOneFlashcardSelection()
        
        // Swipe on the first flashcard to indicate a correct answer
        let flashcardIndex = 0
        let flashcardView = app.otherElements["reviewSessionFlashcardView_\(flashcardIndex)"]
        flashcardView.swipeRight()
        
        print(app.debugDescription)
        // Check for the review session completion screen
        let reviewSessionCompletionView = app.scrollViews["reviewSessionMetricsScreen"]
        XCTAssertTrue(reviewSessionCompletionView.waitForExistence(timeout: 1), "Review session completion screen should exist")
        
        // Check the review session scores
        let correctScoreCount = app.staticTexts["correctScoreReviewSessionSummary"]
        let incorrectScoreCount = app.staticTexts["incorrectScoreReviewSessionSummary"]
        XCTAssertEqual(correctScoreCount.label, "1")
        XCTAssertEqual(incorrectScoreCount.label, "0")
        
        // Check the deck and flashcard completion counts
        let correctDeckCount = app.staticTexts["DeckCompletedCount"]
        XCTAssertEqual(correctDeckCount.label, "1")
        
        let correctFlashcardCount = app.staticTexts["FlashcardCompletedCount"]
        XCTAssertEqual(correctFlashcardCount.label, "1")
    }
}
