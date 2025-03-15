//
//  FlashcardReviewViewState.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Defines an enum representing the states during a flashcard review session.

import Foundation

enum ReviewViewState {
    case isLoading
    case flashcard
    case correctMessage
    case incorrectMessage
    case reviewEnded
}
