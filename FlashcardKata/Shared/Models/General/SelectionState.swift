//
//  SelectionState.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum to manage the selection state (select all or deselect all).

import Foundation

enum SelectionState {
    case selectAll
    case deselectAll

    mutating func toggle() {
        switch self {
        case .selectAll:
            self = .deselectAll
        case .deselectAll:
            self = .selectAll
        }
    }
}
