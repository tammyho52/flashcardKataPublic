//
//  FAQ-MOCK.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Mock data for FAQ.

import Foundation

#if DEBUG
extension FAQ {
    static var mockFAQs: [FAQ] {[
        FAQ(
            question: "What is Swift?",
            answer: "Swift is a programming language developed by Apple Inc. It was released in 2014 and is widely used for iOS development."
        ),
        FAQ(
            question: "What is SwiftUI?",
            answer: "SwiftUI is a framework developed by Apple Inc. It provides a declarative UIKit API for building user interfaces."
        )

    ]}
}
#endif
