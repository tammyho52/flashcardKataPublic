//
//  MockData.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Generates mock data for decks, subdecks, and flashcards.

import Foundation

#if DEBUG
struct MockData {
    // MARK: - Deck / Subdeck IDs
    static let deckIDs = (0..<3).map { index in "deckID_\(index)" }
    static let subdeckIDs = (0..<10).map { index in "subdeckID_\(index)" }

    static let greSubdecks = [subdeck1, subdeck2]
    static let swiftCodingSubdecks = [subdeck3, subdeck4, subdeck5]
    static let japaneseSubdecks = [subdeck6, subdeck7]

    static let greSubdeckIDs = greSubdecks.map { $0.id }
    static let swiftCodingSubdeckIDs = swiftCodingSubdecks.map { $0.id }
    static let japaneseSubdeckIDs = japaneseSubdecks.map { $0.id }

    static let sampleParentDeckWithSubdecksArray: [(Deck, [Deck])] = [
        (deck1, greSubdecks),
        (deck2, swiftCodingSubdecks),
        (deck3, japaneseSubdecks)
    ]

    static let subdeckData: [Deck] = [subdeck1, subdeck2, subdeck3, subdeck4, subdeck5, subdeck6, subdeck7]

    // MARK: - Flashcard IDs
    static let flashcardIDs = (0..<24).map { index in "flashcardID_\(index)" }

    static let greVocabFlashcardIDs = [flashcard1.id, flashcard2.id]
    static let greMathFlashcardIDs = [flashcard3.id, flashcard4.id]

    static let swiftCodingBasicsFlashcardIDs = [flashcard5.id, flashcard6.id, flashcard22.id]
    static let swiftAdvancedTopicsFlashcardIDs = [flashcard7.id, flashcard8.id]
    static let swiftChallengesFlashcardIDs = [flashcard9.id, flashcard10.id]

    static let japaneseVocabFlashcardIDs = [flashcard11.id, flashcard12.id, flashcard13.id]
    static let japaneseGrammarFlashcardIDs = [flashcard14.id, flashcard15.id, flashcard16.id, flashcard17.id]

    // MARK: - Sample Flashcards with More Depth
    static let flashcardData = [
        flashcard1, flashcard2, flashcard3, flashcard4, flashcard5,
        flashcard6, flashcard7, flashcard8, flashcard9, flashcard10,
        flashcard11, flashcard12, flashcard13, flashcard14, flashcard15,
        flashcard16, flashcard17, flashcard18, flashcard19, flashcard20,
        flashcard21, flashcard22
    ]

    static let flashcardsByDeckID: [String: [Flashcard]] = [
        deckIDs[0]: [],
        deckIDs[1]: [flashcardData[17], flashcardData[18]],
        deckIDs[2]: [flashcardData[19], flashcardData[20]],
        subdeckIDs[0]: [flashcardData[0], flashcardData[1]],
        subdeckIDs[1]: [flashcardData[2], flashcardData[3]],
        subdeckIDs[2]: [flashcardData[4], flashcardData[5]],
        subdeckIDs[3]: [flashcardData[6], flashcardData[7]],
        subdeckIDs[4]: [flashcardData[8], flashcardData[9]],
        subdeckIDs[5]: [flashcardData[10], flashcardData[11], flashcardData[12]],
        subdeckIDs[6]: [flashcardData[13], flashcardData[14], flashcardData[15], flashcardData[16]]
    ]
}

extension MockData {
    // MARK: - Sample Decks
    static let deck1 = Deck(
        id: deckIDs[0],
        name: "GRE Concepts",
        theme: .blue,
        subdeckIDs: greSubdeckIDs,
        flashcardIDs: [],
        reviewedFlashcardIDs: []
    )
    static let deck2 = Deck(
        id: deckIDs[1],
        name: "Swift Coding Language",
        theme: .green,
        subdeckIDs: swiftCodingSubdeckIDs,
        flashcardIDs: [flashcard18.id, flashcard19.id],
        reviewedFlashcardIDs: [flashcard18.id]
    )
    static let deck3 = Deck(
        id: deckIDs[2],
        name: "Japanese Language",
        theme: .teal,
        subdeckIDs: japaneseSubdeckIDs,
        flashcardIDs: [flashcard20.id, flashcard21.id],
        reviewedFlashcardIDs: [flashcard20.id, flashcard21.id]
    )

    static let deckData: [Deck] = [deck1, deck2, deck3]

    // MARK: - Sample Subdecks
    static let subdeck1 = Deck(
        id: subdeckIDs[0],
        name: "GRE Vocabulary",
        theme: .blue,
        parentDeckID: deckIDs[0],
        flashcardIDs: greVocabFlashcardIDs,
        reviewedFlashcardIDs: greVocabFlashcardIDs
    )
    static let subdeck2 = Deck(
        id: subdeckIDs[1],
        name: "GRE Math",
        theme: .blue,
        parentDeckID: deckIDs[0],
        flashcardIDs: greMathFlashcardIDs,
        reviewedFlashcardIDs: greMathFlashcardIDs
    )
    static let subdeck3 = Deck(
        id: subdeckIDs[2],
        name: "Swift Coding Basics",
        theme: .green,
        parentDeckID: deckIDs[1],
        flashcardIDs: swiftCodingBasicsFlashcardIDs,
        reviewedFlashcardIDs: swiftCodingBasicsFlashcardIDs
    )
    static let subdeck4 = Deck(
        id: subdeckIDs[3],
        name: "Swift Advanced Topics",
        theme: .green,
        parentDeckID: deckIDs[1],
        flashcardIDs: swiftAdvancedTopicsFlashcardIDs,
        reviewedFlashcardIDs: swiftAdvancedTopicsFlashcardIDs
    )
    static let subdeck5 = Deck(
        id: subdeckIDs[4],
        name: "Swift Code Challenges",
        theme: .green,
        parentDeckID: deckIDs[1],
        flashcardIDs: swiftChallengesFlashcardIDs,
        reviewedFlashcardIDs: swiftChallengesFlashcardIDs
    )
    static let subdeck6 = Deck(
        id: subdeckIDs[5],
        name: "Japanese Vocabulary",
        theme: .teal,
        parentDeckID: deckIDs[2],
        flashcardIDs: japaneseVocabFlashcardIDs,
        reviewedFlashcardIDs: japaneseVocabFlashcardIDs
    )
    static let subdeck7 = Deck(
        id: subdeckIDs[6],
        name: "Japanese Grammar",
        theme: .teal,
        parentDeckID: deckIDs[2],
        flashcardIDs: japaneseGrammarFlashcardIDs,
        reviewedFlashcardIDs: japaneseGrammarFlashcardIDs
    )

    // MARK: - Flashcards
    // GRE Vocabulary
    static let flashcard1 = Flashcard(
        id: flashcardIDs[0],
        userID: "testUserID",
        deckID: subdeckIDs[0],
        frontText: "What is the meaning of ephemeral?",
        backText: "Ephemeral means lasting for a very short time. It is often used to describe things that are fleeting or temporary, like the beauty of a sunset or a short-lived trend.",
        correctReviewCount: 3,
        incorrectReviewCount: 3
    )
    static let flashcard2 = Flashcard(
        id: flashcardIDs[1],
        userID: "testUserID",
        deckID: subdeckIDs[0],
        frontText: "What does obfuscate mean?",
        backText: "To obfuscate means to deliberately make something unclear or difficult to understand. This can refer to actions, explanations, or writing.",
        correctReviewCount: 6,
        incorrectReviewCount: 2
    )

    // GRE Math
    static let flashcard3 = Flashcard(
        id: flashcardIDs[2],
        userID: "testUserID",
        deckID: subdeckIDs[1],
        frontText: "What is the smallest positive integer n that is divisible by both 18 and 30?",
        backText: "The smallest integer divisible by both 18 and 30 is the least common multiple (LCM) of 18 and 30. The prime factorizations of 18 and 30 are 18 = 2 * 3^2 and 30 = 2 * 3 * 5. The LCM is obtained by taking the highest power of each prime factor: LCM = 2 * 3^2 * 5 = 90. Therefore, the smallest integer n is 90.",
        correctReviewCount: 0,
        incorrectReviewCount: 0
    )
    static let flashcard4 = Flashcard(
        id: flashcardIDs[3],
        userID: "testUserID",
        deckID: subdeckIDs[1],
        frontText: "In how many ways can 5 people be arranged in a line if 2 specific people must always be next to each other?",
        backText: "Treat the 2 specific people as one block. This reduces the problem to arranging 4 blocks (the pair and the other 3 people). The number of ways to arrange these 4 blocks is 4! = 24. Since the 2 specific people can be arranged within their block in 2 ways, the total number of arrangements is 4! * 2 = 48.",
        correctReviewCount: 1,
        incorrectReviewCount: 1
    )

    // Swift Coding Basics
    static let flashcard5 = Flashcard(
        id: flashcardIDs[4],
        userID: "testUserID",
        deckID: subdeckIDs[2],
        frontText: "What is the difference between var and let in Swift?",
        backText: "Var is used to declare a variable whose value can be changed, while let is used to declare a constant whose value cannot be changed once it is assigned.",
        difficultyLevel: .easy,
        correctReviewCount: 3,
        incorrectReviewCount: 5
    )
    static let flashcard6 = Flashcard(
        id: flashcardIDs[5],
        userID: "testUserID",
        deckID: subdeckIDs[2],
        frontText: "What does guard do in Swift?",
        backText: "Guard is used to exit a scope early if a condition isn't met, typically in functions and loops. It's useful for validating input before proceeding with the function.",
        difficultyLevel: .medium,
        correctReviewCount: 3,
        incorrectReviewCount: 7
    )
    static let flashcard22 = Flashcard(
        id: flashcardIDs[21],
        userID: "testUserID",
        deckID: subdeckIDs[2],
        frontText: "What is the purpose of optionals in Swift?",
        backText: "Optionals in Swift are used to handle the absence of a value. An optional can either hold a value or be nil, allowing safe handling of variables that may not have a value.",
        difficultyLevel: .hard,
        correctReviewCount: 7,
        incorrectReviewCount: 3
    )

    // Swift Advanced Topics
    static let flashcard7 = Flashcard(
        id: flashcardIDs[6],
        userID: "testUserID",
        deckID: subdeckIDs[3],
        frontText: "What is a closure in Swift?",
        backText: "A closure in Swift is a self-contained block of functionality that can be passed around and used in your code. Closures can capture and store references to variables and constants from the surrounding context.",
        correctReviewCount: 3,
        incorrectReviewCount: 1
    )
    static let flashcard8 = Flashcard(
        id: flashcardIDs[7],
        userID: "testUserID",
        deckID: subdeckIDs[3],
        frontText: "What is an optional binding in Swift?",
        backText: "Optional binding in Swift is a technique used to safely unwrap optionals. It helps prevent runtime errors if the optional value is nil."
    )

    // Swift Code Challenges
    static let flashcard9 = Flashcard(
        id: flashcardIDs[8],
        userID: "testUserID",
        deckID: subdeckIDs[4],
        frontText: "Write a function to reverse a string in Swift.",
        backText: "To reverse a string in Swift, you can use the .reversed() method. For example: let reversed = string.reversed()"
    )
    static let flashcard10 = Flashcard(
        id: flashcardIDs[9],
        userID: "testUserID",
        deckID: subdeckIDs[4],
        frontText: "Write a function to check if a number is prime in Swift.",
        backText: "To check if a number is prime, you can use a loop to check divisibility: for i in 2..<num { if num % i == 0 { return false } } return true.",
        correctReviewCount: 3,
        incorrectReviewCount: 3
    )

    // Japanese Vocabulary
    static let flashcard11 = Flashcard(
        id: flashcardIDs[10],
        userID: "testUserID",
        deckID: subdeckIDs[5],
        frontText: "What does Konnichiwa mean in Japanese?",
        backText: "Konnichiwa means Hello or Good afternoon in Japanese. It is a common greeting used in the middle of the day. Example sentence: Konnichiwa! How are you today?"
    )
    static let flashcard12 = Flashcard(
        id: flashcardIDs[11],
        userID: "testUserID",
        deckID: subdeckIDs[5],
        frontText: "What does Arigatou gozaimasu mean in Japanese?",
        backText: "Arigatou gozaimasu means Thank you or Thank you very much in Japanese. It is a polite expression used to show gratitude. Example sentence: Arigatou gozaimasu for helping me with the project!",
        correctReviewCount: 6,
        incorrectReviewCount: 3
    )
    static let flashcard13 = Flashcard(
        id: flashcardIDs[12],
        userID: "testUserID",
        deckID: subdeckIDs[5],
        frontText: "What does Sayounara mean in Japanese?",
        backText: "Sayounara means Goodbye in Japanese. It is a formal way of bidding farewell, typically used when you are not expecting to see the person again soon. Example sentence: Sayounara! I hope to see you again soon."
    )

    // Japanese Grammar
    static let flashcard14 = Flashcard(
        id: flashcardIDs[13],
        userID: "testUserID",
        deckID: subdeckIDs[6],
        frontText: "How do you say 'I am a student' in Japanese?",
        backText: "'私は学生です' (Watashi wa gakusei desu) means 'I am a student.' '私' (watashi) means 'I', 'は' (wa) is the topic marker, '学生' (gakusei) means 'student', and 'です' (desu) is the polite form of the verb 'to be'."
    )
    static let flashcard15 = Flashcard(
        id: flashcardIDs[14],
        userID: "testUserID",
        deckID: subdeckIDs[6],
        frontText: "What is the particle は (wa) used for?",
        backText: "The particle は (wa) is used to mark the topic of a sentence. It is pronounced 'wa' although written as 'は'. Example sentence: 私は学生です (I am a student).",
        correctReviewCount: 4,
        incorrectReviewCount: 3
    )
    static let flashcard16 = Flashcard(
        id: flashcardIDs[15],
        userID: "testUserID",
        deckID: subdeckIDs[6],
        frontText: "What does いただきます mean?",
        backText: "いただきます (Itadakimasu) is a phrase said before eating, expressing gratitude for the meal. It shows respect to the people who prepared the food. Example: いただきます、ありがとうございました (Itadakimasu, thank you very much)."
    )
    static let flashcard17 = Flashcard(
        id: flashcardIDs[16],
        userID: "testUserID",
        deckID: subdeckIDs[6],
        frontText: "How do you conjugate the verb 食べる (taberu) into its past tense?",
        backText: "食べる (taberu) becomes 食べた (tabeta) in the past tense. This is a regular verb conjugation.",
        correctReviewCount: 5,
        incorrectReviewCount: 2
    )

    // General Swift Coding
    static let flashcard18 = Flashcard(
        id: flashcardIDs[17],
        userID: "testUserID",
        deckID: deckIDs[1],
        frontText: "What are the main differences between value types (like structs) and reference types (like classes) in Swift?",
        backText: "Value types (structs, enums) are copied when assigned to a new variable or passed to a function, while reference types (classes) are passed by reference, meaning changes to one instance affect all references."
    )
    static let flashcard19 = Flashcard(
        id: flashcardIDs[18],
        userID: "testUserID",
        deckID: deckIDs[1],
        frontText: "How does Swift implement error handling, and what is the role of `do-catch`?",
        backText: "Swift uses `do-catch` for error handling. You place throwing functions inside a `do` block and catch errors with a `catch` block to handle them appropriately."
    )

    // Japanese Language
    static let flashcard20 = Flashcard(
        id: flashcardIDs[19],
        userID: "testUserID",
        deckID: deckIDs[2],
        frontText: "What are the three main writing systems in Japanese?",
        backText: "Japanese uses three main writing systems: Hiragana, Katakana, and Kanji. Hiragana is used for native words and grammatical elements, Katakana for foreign words and onomatopoeia, and Kanji for Chinese characters that represent words or ideas.",
        correctReviewCount: 10,
        incorrectReviewCount: 6
    )
    static let flashcard21 = Flashcard(
        id: flashcardIDs[20],
        userID: "testUserID",
        deckID: deckIDs[2],
        frontText: "How does Japanese sentence structure differ from English?",
        backText: "Japanese follows a Subject-Object-Verb (SOV) order, whereas English follows a Subject-Verb-Object (SVO) order. For example, 'I eat sushi' in English would be structured as 'I sushi eat' in Japanese."
    )
}

#endif
