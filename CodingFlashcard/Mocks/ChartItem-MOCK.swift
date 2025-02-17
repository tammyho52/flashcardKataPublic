//
//  ChartItem-MOCK.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

#if DEBUG
extension ChartItem {
    static let sampleArray = [
        ChartItem(deck: Deck.sampleDeckArray[0], flashcardsReviewed: [UUID().uuidString: true, UUID().uuidString: false]),
        ChartItem(deck: Deck.sampleDeckArray[1], flashcardsReviewed: [UUID().uuidString: true, UUID().uuidString: false]),
        ChartItem(deck: Deck.sampleDeckArray[2], flashcardsReviewed: [UUID().uuidString: true, UUID().uuidString: false, UUID().uuidString: true, UUID().uuidString: true])
    ]
}
#endif
