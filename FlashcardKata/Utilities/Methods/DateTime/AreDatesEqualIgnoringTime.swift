//
//  AreDatesEqualIgnoringTime.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to compare two dates for equality, ignoring time.

import Foundation

/// Function to compare two dates for equality, ignoring time.
func areDatesEqualIgnoringTime(_ date1: Date, _ date2: Date) -> Bool {
    let calendar = Calendar.current

    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
    return components1 == components2
}
