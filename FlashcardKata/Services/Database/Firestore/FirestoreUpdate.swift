//
//  FirestoreUpdate.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Structure that represents an add, remove, or update operation on a Firestore document.

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
