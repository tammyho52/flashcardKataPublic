//
//  CalendarPieChartData.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model represents data for the tracker pie chart, which includes information
//  on a parent deck and the flashcards reviewed within the deck.

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
