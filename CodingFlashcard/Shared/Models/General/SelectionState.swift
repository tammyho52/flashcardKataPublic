//
//  SelectionState.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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


