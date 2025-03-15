//
//  Firestorable.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Protocol for data types that can be stored in Firestore.

import Foundation

protocol Firestorable {
    var id: String { get set }
    var userID: String? { get set }
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String
}
