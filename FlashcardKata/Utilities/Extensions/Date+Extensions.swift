//
//  Date+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A collection of date utility methods for simplifying data calculations and comparisons.

import Foundation

extension Date {
    /// Returns a string representing the time interval since the date.
    func timeAgo() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self, to: Date())

        if let years = components.year, years != 0 {
            return "\(years) year\(years == 1 ? "" : "s") ago"
        }

        if let months = components.month, months != 0 {
            return "\(months) month\(months == 1 ? "" : "s") ago"
        }

        if let days = components.day, days != 0 {
            if days >= 7 {
                let weeks = days / 7
                return "\(weeks) week\(weeks == 1 ? "" : "s") ago"
            } else {
                return "\(days) day\(days == 1 ? "" : "s") ago"
            }
        }
        return "Today"
    }
}
