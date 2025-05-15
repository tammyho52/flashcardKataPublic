//
//  Optional+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Extension to handle optional values in a generic way.

import Foundation

protocol OptionalProtocol {
    func setOptionalValue() -> Any
}

extension Optional: OptionalProtocol {
    /// Set optional data types to NSNull explicitly for Firestore.
    func setOptionalValue() -> Any {
        switch self {
        case .none: return NSNull()
        case .some(let value):
            return value
        }
    }
}
