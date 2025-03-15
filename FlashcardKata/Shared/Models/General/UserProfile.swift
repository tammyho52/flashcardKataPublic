//
//  DBUser.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Model to store and manage user's profile information.

import Foundation
import FirebaseAuth

struct UserProfile: Codable, Hashable {
    var id: String = UUID().uuidString
    var userID: String?
    var dateCreated: Date = Date()
    var name: String = ""
    var email: String = ""
}

extension UserProfile: Firestorable {
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        switch keyPath {
        case \UserProfile.userID:
            return "userID"
        case \UserProfile.dateCreated:
            return "dateCreated"
        case \UserProfile.name:
            return "name"
        case \UserProfile.email:
            return "email"
        default:
            return ""
        }
    }
}

extension UserProfile {
    init(user: User) {
        self.id = user.uid
        self.userID = user.uid
        self.name = user.displayName ?? ""
        self.email = user.email ?? ""
    }
}
