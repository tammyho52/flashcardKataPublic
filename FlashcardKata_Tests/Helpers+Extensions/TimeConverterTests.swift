//
//  TimeConverterTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing

struct TimeConverterTests {

    @Test func testFormattedShortTime_AtLeastTwoMinutes() async throws {
        let totalSeconds = 5000
        let timeConverter = TimeConverter(totalSeconds: totalSeconds)
        
        let result = timeConverter.formattedShortTime()
        let expected = "1 hour, 23 minutes"
        #expect(result == expected)
    }
    
    @Test func testFormattedShortTime_OneMinute() async throws {
        let totalSeconds = 119 // Less than two minutes = "One minute"
        let timeConverter = TimeConverter(totalSeconds: totalSeconds)
        
        let result = timeConverter.formattedShortTime()
        let expected = "1 minute"
        #expect(result == expected)
    }

    
    @Test func testFormattedShortTime_ZeroSeconds() async throws {
        let totalSeconds = 0
        let timeConverter = TimeConverter(totalSeconds: totalSeconds)
        
        let result = timeConverter.formattedShortTime()
        let expected = "0 seconds"
        #expect(result == expected)
    }
    
    @Test func testFormattedNumericTime_AtLeastOneHour() async throws {
        let totalSeconds = 5000
        let timeConverter = TimeConverter(totalSeconds: totalSeconds)
        
        let result = timeConverter.formattedNumericTime()
        let expected = "1:23"
        #expect(result == expected)
    }
    
    @Test func testFormattedNumericTime_LessThanOneHour() async throws {
        let totalSeconds = 2000
        let timeConverter = TimeConverter(totalSeconds: totalSeconds)
        
        let result = timeConverter.formattedNumericTime()
        let expected = "0:33"
        #expect(result == expected)
    }
    
    @Test func testFormattedNumericTime_OneMinute() async throws {
        let totalSeconds = 50
        let timeConverter = TimeConverter(totalSeconds: totalSeconds)
        
        let result = timeConverter.formattedNumericTime()
        let expected = "0:01"
        #expect(result == expected)
    }
    
    @Test func testFormattedNumericTime_ZeroSeconds() async throws {
        let totalSeconds = 0
        let timeConverter = TimeConverter(totalSeconds: totalSeconds)
        
        let result = timeConverter.formattedNumericTime()
        let expected = "0:00"
        #expect(result == expected)
    }
}
