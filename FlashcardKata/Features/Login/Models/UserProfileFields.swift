//
//  UserProfile.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Stores user profile information for sign up.

import Foundation

struct UserProfileFields: Codable, Equatable, Hashable {
    var userID: String?
    var dateCreatedAt: Date
    var name: String = ""
    var email: String = ""
    var authenticationProvider: String
}

extension UserProfileFields: Firestorable {
    var id: String {
        get {
            return userID ?? ""
        }
        set {
            userID = newValue
        }
    }

    // Maps UserProfileFields properties to Firestore field names.
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
