//
//  TimeConverter.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility structure for converting time into various time units and display formats.

import Foundation
import SwiftUI

/// Converts time in seconds to a formatted string representation.
struct TimeConverter {
    let totalSeconds: Int

    /// Return formatted time in a short string format (e.g., "1 hour, 30 minutes").
    func formattedShortTime() -> String {
        // Handle special cases for 0 seconds
        guard totalSeconds > 0 else {
            return "0 seconds"
        }
        
        // Handle special case for less than 2 minutes, which rounds to "1 minute"
        if totalSeconds <= 119 {
            return "1 minute"
        }
        
        var resultParts: [String] = []
        var remainingSeconds = totalSeconds
        
        let hours = getHours(totalSeconds: remainingSeconds)
        if hours > 0 {
            resultParts.append("\(hours) hour\(hours > 1 ? "s" : "")")
            remainingSeconds %= 3600
        }
        
        let minutes = getMinutes(totalSeconds: remainingSeconds)
        if minutes > 0 {
            resultParts.append("\(minutes) minute\(minutes > 1 ? "s" : "")")
        }

        return resultParts.isEmpty ? "Not Available" : resultParts.joined(separator: ", ")
    }
    
    /// Return formatted time in numeric format of H:MM
    func formattedNumericTime() -> String {
        switch totalSeconds {
        case 0:
            return "0:00"
        case 1..<60:
            return "0:01"
        default:
            let hours = getHours(totalSeconds: totalSeconds)
            let remainingSeconds = totalSeconds % 3600
            let minutes = getMinutes(totalSeconds: remainingSeconds)
            return String(format: "%d:%02d", hours, minutes)
        }
    }
    
    // Helper Methods
    /// Calculates the number of hours from total seconds.
    private func getHours(totalSeconds: Int) -> Int {
        return totalSeconds / 3600
    }
    
    /// Calculates the number of minutes from total seconds.
    private func getMinutes(totalSeconds: Int) -> Int {
        return totalSeconds / 60
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    Text("\(TimeConverter(totalSeconds: 60 * 60).formattedShortTime())")
    Text("\(TimeConverter(totalSeconds: 60).formattedShortTime())")
    Text("\(TimeConverter(totalSeconds: 50).formattedShortTime())")
    Text("\(TimeConverter(totalSeconds: 61).formattedNumericTime())")
    Text("\(TimeConverter(totalSeconds: 0).formattedNumericTime())")
}
#endif
