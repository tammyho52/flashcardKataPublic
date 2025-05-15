//
//  DatabaseManagerPublisherProtocol.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Protocol for database manager publishers.

import Foundation

@MainActor
protocol DatabaseManagerPublisherProtocol {
    var decksPublisher: Published<[Deck]>.Publisher { get }
    var subdecksPublisher: Published<[Deck]>.Publisher { get }
    var flashcardsPublisher: Published<[Flashcard]>.Publisher { get }
    var errorMessagePublisher: Published<String?>.Publisher { get }
}
