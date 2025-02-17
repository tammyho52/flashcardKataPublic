//
//  LayoutType.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

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
