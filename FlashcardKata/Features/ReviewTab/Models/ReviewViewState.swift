//
//  FlashcardReviewViewState.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  An enum representing the view states during a flashcard review session.

import Foundation

/// Enum representing the different view states during a flashcard review session.
enum ReviewViewState {
    /// The view is loading
    case isLoading
    
    /// The view is displaying a flashcard for review
    case flashcard
    
    /// The view is displaying a correct answer message
    case correctMessage
    
    /// The view is displaying an incorrect answer message
    case incorrectMessage
    
    /// The view is displaying a summary of the review session
    case reviewEnded
}
