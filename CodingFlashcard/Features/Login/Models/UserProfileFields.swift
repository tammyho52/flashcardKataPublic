//
//  UserProfile.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
