//
//  FirestoreUpdate.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

struct FirestoreUpdate {
    var field: String
    var operation: FirestoreUpdateOperation
}

extension FirestoreUpdate {
    enum FirestoreUpdateOperation {
        case add(values: [Any])
        case remove(values: [Any])
        case update(value: Any)
    }
}
