//
//  CalendarPieChartData.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ChartItem {
    let deck: Deck
    let flashcardsReviewed: [String: Bool]
}

extension ChartItem: Identifiable {
    var id: String {
        return deck.id
    }
    
    var primaryColor: Color {
        deck.isSubdeck ? deck.theme.secondaryColor : deck.theme.primaryColor
    }
    
    var flashcardCount: Int {
        flashcardsReviewed.count
    }
    
    var percentCorrect: Double {
        (Double(flashcardsReviewed.filter(\.value).count) / Double(flashcardsReviewed.count)) * 100
    }
}
