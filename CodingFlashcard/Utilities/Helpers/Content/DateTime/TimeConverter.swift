//
//  TimeConverter.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation
import SwiftUI

struct TimeConverter {
    let totalSeconds: Int
    
    init(totalSeconds: Int) {
        self.totalSeconds = totalSeconds
    }
    
    init(minutes: Int) {
        self.init(totalSeconds: minutes * 60)
    }
    
    init(hours: Int) {
        self.init(minutes: hours * 60)
    }
    
    init(days: Int) {
        self.init(hours: days * 24)
    }
    
    var months: Int {
        return totalSeconds / 2592000
    }
    
    var weeks: Int {
        return (totalSeconds % 2592000) / 604800
    }
    
    var days: Int {
        return (totalSeconds % 604800) / 86400
    }
    
    var hours: Int {
        return (totalSeconds % 86400) / 3600
    }
    
    var minutes: Int {
        return (totalSeconds % 3600) / 60
    }
    
    var seconds: Int {
        return totalSeconds % 60
    }
    
    func formattedDate(includeHours: Bool = false, includeMinutes: Bool = false, includeSeconds: Bool = false) -> String {
        if months > 0 {
            return "\(months) month\(months > 1 ? "s" : "")"
        }
        
        if weeks > 0 {
            return "\(weeks) week\(weeks > 1 ? "s" : "")"
        }
        
        if days > 0 {
            return "\(days) day\(days > 1 ? "s" : "")"
        }
        
        if includeHours, hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        }
        
        if includeMinutes, minutes > 0 {
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
        
        if includeSeconds, seconds > 0 {
            return "\(seconds) second\(seconds > 1 ? "s" : "")"
        }
        return ""
    }
    
    func formattedShortTime(includeHours: Bool = true, includeMinutes: Bool = true, includeSeconds: Bool = true) -> String {
        if hours > 0, includeHours {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        }
        
        if minutes > 0, includeMinutes {
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
        
        if seconds > 0, includeSeconds {
            return "\(seconds) second\(seconds > 1 ? "s" : "")"
        }
        return "Not Available"
    }
    
    func formattedNumericTime() -> String {
        if totalSeconds == 0 {
            return "0:00"
        } else if totalSeconds < 60 {
            return "0:01"
        } else {
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            return String(format: "%d:%02d", hours, minutes)
        }
    }
}

#if DEBUG
#Preview {
    Text("\(TimeConverter(totalSeconds: 60 * 60).formattedShortTime())")
    Text("\(TimeConverter(totalSeconds: 60).formattedShortTime())")
    Text("\(TimeConverter(totalSeconds: 50).formattedShortTime())")
    Text("\(TimeConverter(totalSeconds: 61).formattedNumericTime())")
    Text("\(TimeConverter(totalSeconds: 0).formattedNumericTime())")
}
#endif
