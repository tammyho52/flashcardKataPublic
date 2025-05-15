//
//  ChartItem.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This model represents data for the tracker pie chart, including information
//  on a parent deck and the flashcards reviewed within the deck.

import SwiftUI

/// A model representing data for the tracker pie chart.
struct ChartItem {
    let deck: Deck
    let flashcardReviewResults: [String: Bool] // Bool = isCorrect
    
    var primaryColor: Color {
        deck.isSubdeck ? deck.theme.secondaryColor : deck.theme.primaryColor
    }

    var flashcardCount: Int {
        flashcardReviewResults.count
    }

    var percentCorrect: Double {
        (Double(flashcardReviewResults.filter(\.value).count) / Double(flashcardReviewResults.count)) * 100
    }
}

extension ChartItem: Identifiable {
    var id: String {
        return deck.id
    }
}
