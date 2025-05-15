//
//  DateExtensionTests.swift
//  FlashcardKataTests
//
//  Created by Tammy Ho.
//

import Testing
import Foundation

struct DateExtensionTests {

    @Test func testTimeAgo_today() async throws {
        let today = Date()
        let result = today.timeAgo()
        #expect(result == "Today")
    }
    
    @Test func testTimeAgo_daysAgo() async throws {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = oneDayAgo.timeAgo()
        #expect(result == "1 day ago")
        
        let sixDaysAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        let result2 = sixDaysAgo.timeAgo()
        #expect(result2 == "6 days ago")
    }
    
    @Test func testTimeAgo_weeksAgo() async throws {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let result = sevenDaysAgo.timeAgo()
        #expect(result == "1 week ago")
        
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let result2 = fourteenDaysAgo.timeAgo()
        #expect(result2 == "2 weeks ago")
    }
    
    @Test func testTimeAgo_monthsAgo() async throws {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let result = oneMonthAgo.timeAgo()
        #expect(result == "1 month ago")
        
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date())!
        let result2 = threeMonthsAgo.timeAgo()
        #expect(result2 == "3 months ago")
    }
    
    @Test func testTimeAgo_yearsAgo() async throws {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let result = oneYearAgo.timeAgo()
        #expect(result == "1 year ago")
        
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let result2 = twoYearsAgo.timeAgo()
        #expect(result2 == "2 years ago")
    }
}
