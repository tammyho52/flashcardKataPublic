//
//  SubdeckName-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generate mock data for subdeck names.

import Foundation

#if DEBUG
extension SubdeckName {
    static let sampleSubdeckName: SubdeckName = SubdeckName(name: "Software Engineering")
    static let sampleSubdeckNameArray: [SubdeckName] = [
        SubdeckName(name: "Software Engineering 1"),
        SubdeckName(name: "Software Engineering 2"),
        SubdeckName(name: "Software Engineering 3")
    ]
}
#endif
