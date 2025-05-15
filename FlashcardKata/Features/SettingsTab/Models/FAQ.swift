//
//  FAQ.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This model represents a Frequently Asked Question (FAQ) as a question and answer pair.

import Foundation

/// A model representing a Frequently Asked Question (FAQ) with a question and answer pair.
struct FAQ: Codable, Identifiable {
    // MARK: - Properties
    let id: String
    let questionText: String
    let answerText: String

    // MARK: - Initializers
    /// Initializes a new FAQ instance with the provided question and answer.
    init(question: String, answer: String) {
        self.id = UUID().uuidString
        self.questionText = question
        self.answerText = answer
    }

    /// Initializes a new FAQ instance from a decoder.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        questionText = try container.decode(String.self, forKey: .questionText)
        answerText = try container.decode(String.self, forKey: .answerText)

        self.id = UUID().uuidString
    }
    
    // MARK: - Coding Keys
    /// Enum to map the property names to the keys in the JSON data.
    private enum CodingKeys: String, CodingKey {
        case questionText = "question"
        case answerText = "answer"
    }
}
