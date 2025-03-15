//
//  LayoutType.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Defines the layout for flashcards.

import SwiftUI

enum FlashcardLayout {
    case frontOnly
    case frontAndBack
}

extension FlashcardLayout {
    mutating func toggle() {
        self = (self == .frontOnly) ? .frontAndBack : .frontOnly
    }
}
