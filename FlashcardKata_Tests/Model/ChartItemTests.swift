//
//  ChartItemTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing
import SwiftUI

struct ChartItemTests {

    @Test func testPrimaryColorForDeck() {
        let chartItem = ChartItem.sampleArray[0]
        #expect(chartItem.primaryColor == ColorPalette.Theme.darkBlue)
    }
    
    @Test func testPrimaryColorForSubdeck() {
        let chartItem = ChartItem.sample
        #expect(chartItem.primaryColor == ColorPalette.Theme.lightBlue)
    }
    
    @Test func testFlashcardCount() {
        let chartItem = ChartItem.sampleArray[0]
        #expect(chartItem.flashcardCount == 2)
    }
    
    @Test func testPercentCorrect() {
        let chartItem = ChartItem.sampleArray[0]
        #expect(chartItem.percentCorrect == 50.0)
    }
}
