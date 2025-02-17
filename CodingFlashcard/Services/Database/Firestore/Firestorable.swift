//
//  Firestorable.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

protocol Firestorable {
    var id: String { get set }
    var userID: String? { get set }
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String
}
