//
//  FirestoreUpdate.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure that represents an add, remove, or update operation on a Firestore document.

import Foundation

struct DatabaseUpdate {
    var field: String
    var operation: DatabaseUpdateOperation
}

extension DatabaseUpdate {
    enum DatabaseUpdateOperation {
        case add(values: [Any])
        case remove(values: [Any])
        case update(value: Any)
        case increment(value: Int)
    }
}
