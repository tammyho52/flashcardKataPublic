//
//  ExpansionState.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
