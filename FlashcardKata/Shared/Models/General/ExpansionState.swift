//
//  ExpansionState.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum to manage the expansion state (expand all or collapse all).

import Foundation

enum ExpansionState {
    case expandAll
    case collapseAll

    mutating func toggle() {
        switch self {
        case .expandAll:
            self = .collapseAll
        case .collapseAll:
            self = .expandAll
        }
    }
}
