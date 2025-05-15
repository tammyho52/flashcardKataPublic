//
//  Firestorable.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Protocol for data types that can be stored in Firestore.

import Foundation

protocol Firestorable: Codable & Equatable & Hashable {
    var id: String { get set }
    var userID: String? { get set }
    
    /// Converts key paths to Firestore-compatible field names.
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String
}

extension Firestorable {
    /// Converts the value to a Firestore-compatible value.
    static func convertToFirestoreValue(value: Any) -> Any {
        FirestoreValueConverter.convert(value)
    }
}

/// An enum to handle the conversion of custom data types and optional data types to Firestore-compatible values.
enum FirestoreValueConverter {
    /// Converts custom data types and optional data types to Firestore-compatible values.
    static func convert(_ value: Any) -> Any {
        if let optionalValue = value as? OptionalProtocol {
            return optionalValue.setOptionalValue() // Converts nil to NSNull
        }
        
        // Converts custom data types to their raw values.
        switch value {
        case let theme as Theme:
            return theme.rawValue
        case let difficultyLevel as DifficultyLevel:
            return difficultyLevel.rawValue
        case let reviewMode as ReviewMode:
            return reviewMode.rawValue
        default:
            return value // For all other types, return the value as is.
        }
    }
}
