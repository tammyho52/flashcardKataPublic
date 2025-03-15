//
//  FAQ.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Model representing a FAQ as a question and answer pair.

import Foundation

struct FAQ: Codable, Identifiable {
    let id: String
    let question: String
    let answer: String

    init(question: String, answer: String) {
        self.id = UUID().uuidString
        self.question = question
        self.answer = answer
    }

    enum CodingKeys: String, CodingKey {
        case question
        case answer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(String.self, forKey: .question)
        answer = try container.decode(String.self, forKey: .answer)

        self.id = UUID().uuidString
    }
}

extension FAQ {
    static var mockFAQs: [FAQ] {[
        FAQ(
            question: "What is Swift?",
            answer: """
                    Swift is a programming language developed by Apple Inc.
                    It was released in 2014 and is widely used for iOS development.
            """
        ),
        FAQ(
            question: "What is SwiftUI?",
            answer: """
                    SwiftUI is a framework developed by Apple Inc.
                    It provides a declarative UIKit API for building user interfaces.
            """
        )

    ]}
}
