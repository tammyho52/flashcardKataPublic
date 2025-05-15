//
//  LayoutType.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Defines the layout options for flashcards and provides functionality to toggle between them.

import SwiftUI

/// Represents the layout types for flashcards.
enum FlashcardLayout {
    /// A layout that displays only the front side of the flashcard (associated with flashcards that can flip to view back side).
    case frontOnly
    /// A layout that displays both the front and back sides of the flashcard.
    case frontAndBack
}

extension FlashcardLayout {
    /// Toggles the layout type.
    mutating func toggle() {
        self = (self == .frontOnly) ? .frontAndBack : .frontOnly
    }
}
