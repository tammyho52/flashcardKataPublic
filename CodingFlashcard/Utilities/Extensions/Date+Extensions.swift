//
//  Date+Extensions.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

extension Date {
    func daysAgo() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: Date())
        return abs(components.day ?? 0)
    }
    
    func monthsAgo() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: self, to: Date())
        return abs(components.month ?? 0)
    }
    
    func yearsAgo() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self, to: Date())
        return abs(components.year ?? 0)
    }
    
    func timeAgo() -> String {
        let years = yearsAgo()
        if years != 0 {
            return "\(years) years ago"
        }
        
        let months = monthsAgo()
        if months != 0 {
            return "\(months) months ago"
        }
        
        let days = daysAgo()
        if days != 0 {
            return "\(days) days ago"
        }
        
        return "Today"
    }
    
    func calculateDate(byAdding: Calendar.Component, value: Int, to date: Date = Date()) -> Date {
        if let nextDate = Calendar.current.date(byAdding: byAdding, value: value, to: date) {
            return nextDate
        }
        return Date()
    }
    
    func compare(to date: Date, for components: Set<Calendar.Component>, using comparison: (Int, Int) -> Bool) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents(components, from: self)
        let dateComponents = calendar.dateComponents(components, from: date)
        
        if components.contains(.year), let year1 = selfComponents.year, let year2 = dateComponents.year {
            if comparison(year1, year2) {
                return true
            }
        }
        
        if components.contains(.month), let month1 = selfComponents.month, let month2 = dateComponents.month {
            return comparison(month1, month2)
        }
        
        if components.contains(.day), let day1 = selfComponents.day, let day2 = dateComponents.day {
            return comparison(day1, day2)
        }
        return false
    }
    
    func isEqualToToday() -> Bool {
        return compare(to: Date(), for: [.day], using: ==)
    }
}
