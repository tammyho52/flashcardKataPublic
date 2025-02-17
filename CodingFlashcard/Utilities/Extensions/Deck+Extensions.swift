//
//  DeckExtensions.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

extension Deck {
    static func makeDecks(for deckNames: [String], parentDeckID: String? = nil) -> [Deck] {
        if let parentDeckID {
            return deckNames.map { Deck(name: $0, parentDeckID: parentDeckID) }
        } else {
            return deckNames.map { Deck(name: $0) }
        }
    }
}

// Calculates Most Recent Date from Array of Dates
extension Array where Element == Date {
    func mostRecentDate() -> Date? {
        self.isEmpty ? nil : self.sorted(by: >).first
    }
}

//Counts number of items based on an integer and item name
extension Int {
    func countAsString(for item: String) -> String {
        switch self {
        case 0:
            return "No \(item)s"
        case 1:
            return "1 \(item)"
        default:
            return "\(self) \(item)s"
        }
    }
}

extension Date {
    func timeElapsed() -> DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
    }
    
    func timeElapsedText() -> String {
        let timeElapsed = timeElapsed()
        let daysElapsed = timeElapsed.day
        let monthsElapsed = timeElapsed.month
        let yearsElapsed = timeElapsed.year
        var output = ""
        if let daysElapsed, daysElapsed != 0 {
            output = "\(daysElapsed) \(daysElapsed == 1 ? "day" : "days")" + " ago"
            if let monthsElapsed, monthsElapsed != 0 {
                output = "\(monthsElapsed) \(monthsElapsed == 1 ? "month, " : "months, ")" + output
                if let yearsElapsed, yearsElapsed != 0 {
                    output = "\(yearsElapsed) \(yearsElapsed == 1 ? "year, " : "years, ")" + output
                }
            }
        }
        return output
    }
}


