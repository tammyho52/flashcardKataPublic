//
//  FlashcardReviewStatisticsTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing

struct FlashcardReviewStatisticsTests {

    @Test func testTotalReviewCount() async throws {
        let statistics = FlashcardReviewStatistics.sample
        #expect(statistics.totalReviewCount == 6)
    }
    
    @Test func testCorrectPercentage_WhenNonZero() async throws {
        let statistics = FlashcardReviewStatistics.sample
        #expect(statistics.correctPercentage == 50.0)
    }
    
    @Test func testCorrectPercentage_WhenZero() async throws {
        let statistics = FlashcardReviewStatistics.sampleArray[2]
        #expect(statistics.correctPercentage == 0.0)
    }
    
    @Test func testIncorrectPercentage_WhenNonZero() async throws {
        let statistics = FlashcardReviewStatistics.sample
        #expect(statistics.incorrectPercentage == 50.0)
    }
    
    @Test func testIncorrectPercentage_WhenZero() async throws {
        let statistics = FlashcardReviewStatistics.sampleArray[2]
        #expect(statistics.incorrectPercentage == 0.0)
    }
}
