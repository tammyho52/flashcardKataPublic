//
//  DeckReviewStatisticsTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing

struct DeckReviewStatisticsTests {

    @Test func testProgressPercentage_WhenNoCardsReviewed() async throws {
        let statistics = DeckReviewStatistics.sampleArray[0]
        #expect(statistics.progressPercentage == 0.0)
    }
    
    @Test func testProgressPercentage_WhenCardsReviewed() async throws {
        let statistics = DeckReviewStatistics.sampleArray[1]
        #expect(statistics.progressPercentage == 0.5)
    }
    
    @Test func testProgressPercentage_WithNoProgress() async throws {
        let statistics = DeckReviewStatistics.sampleArray[0]
        #expect(statistics.progressPercentageString == "0.0%")
    }
    
    @Test func testProgressPercentage_WithProgress() async throws {
        let statistics = DeckReviewStatistics.sampleArray[1]
        #expect(statistics.progressPercentageString == "50.0%")
    }
    
    @Test func testReviewText() async throws {
        let statistics = DeckReviewStatistics.sampleArray[1]
        #expect(statistics.reviewText == "1/2 Cards")
    }
}
