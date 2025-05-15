//
//  ContentConstants.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Central resposity for content-related constants in the app.

import Foundation

struct ContentConstants {
    static let cacheLimit: Int = 20
    static let fetchItemLimit: Int = 10
    
    // MARK: - Content Constants
    struct ContentStrings {
        static let appName: [[String]] = [["F", "L", "A", "S", "H", "C", "A", "R", "D"], ["K", "A", "T", "A"]]
        static let privatePolicyURL: String =
            "https://docs.google.com/document/d/1BcJoqA3V7dW9uGQZkhbQAJ3LCFaGYgcJqkZiDwi_35E/edit?usp=sharing"
        static let termsAndConditionsURL: String =
            "https://docs.google.com/document/d/14j4T92VwLIxw_lBmgxXr3cKzRgpsNKtCnqdcL0oUfks/edit?usp=sharing"
        static let faqJSONURL: String =
            "https://raw.githubusercontent.com/FlashcardKata/json-files/main/FlashcardKataFAQ.json"
        static let unexpectedErrorMessage: String = "An unexpected error occurred. Please try again."
    }

    // MARK: - Image Constants
    struct Images {
        static let appBackgroundImage: String = "Ocean"
    }

    // MARK: - Symbol Constants
    struct Symbols {
        static let flashcard: String = "rectangle.on.rectangle.angled"
        static let deck: String = "dock.rectangle"
        static let helpCenter: String = "questionmark.circle.fill"
        static let termsAndConditions: String = "doc.text.fill"
        static let privatePolicy: String = "doc.fill"
        static let rateUs: String = "suit.heart.fill"
        static let password: String = "lock.fill"
        static let confirmPassword: String = "lock.rotation"
        static let name: String = "person.fill"
        static let email: String = "globe"
        static let profile: String = "person.crop.circle.fill"
        static let signOut: String = "key.horizontal.fill"
        static let deleteAccount: String = "trash.fill"
        static let difficultyLevel: String = "mountain.2"
        static let hint: String = "lightbulb"
        static let shuffle: String = "shuffle"
        static let customFlashcardMode: String = "square.grid.2x2.fill"
        static let signUpAndLogin: String = "door.left.hand.open"
        static let menu: String = "line.3.horizontal"
        static let repeatCount: String = "repeat"
        static let correctScore: String = "hand.thumbsup.fill"
        static let incorrectScore: String = "hand.thumbsdown.fill"
    }
}
