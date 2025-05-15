//
//  UserProfile.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Stores user profile information for all users.

import Foundation

/// Data model representing a user's profile information after sign up.
struct UserProfileFields: Codable, Equatable, Hashable {
    var userID: String? // Set to String to match Firestore's document ID type.
    var dateCreatedAt: Date
    var name: String = ""
    var email: String = ""
    var authenticationProvider: String
}

// MARK: - Firestorable
extension UserProfileFields: Firestorable {
    /// The document ID in Firestore is the userID.
    var id: String {
        get {
            return userID ?? ""
        }
        set {
            userID = newValue
        }
    }

    /// Maps Swift's `KeyPath` to Firestore field names.
    /// - Parameter keyPath: The key path of the property.
    /// - Returns: The corresponding Firestore field name.
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        switch keyPath {
        case \UserProfileFields.userID:
            return "userID"
        case \UserProfileFields.dateCreatedAt:
            return "dateCreatedAt"
        case \UserProfileFields.name:
            return "name"
        case \UserProfileFields.email:
            return "email"
        case \UserProfileFields.authenticationProvider:
            return "authenticationProvider"
        default:
            return ""
        }
    }
}
