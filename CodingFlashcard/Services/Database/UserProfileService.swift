//
//  UserProfileManager.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation
import Firebase
import FirebaseFirestore

final class UserProfileService: ObservableObject {
    
    private let collectionPath: String = FirestoreCollectionPath.userProfile.rawValue
    private let databaseService: FirestoreService<UserProfile, String>
    
    init() {
        self.databaseService = FirestoreService<UserProfile, String>(collectionPath: collectionPath, orderByKeyPath: \UserProfile.id, orderDirection: .descending)
    }
    
    func createUserProfile(_ userProfile: UserProfile) async throws {
        try await databaseService.create(userProfile)
    }
    
    func fetchUserProfile(id: String) async throws -> UserProfile? {
        return try await databaseService.fetch(id: id)
    }
    
    func updateUserProfile(userProfile: UserProfile) async throws {
        try await databaseService.update(userProfile)
    }
    
    func deleteUserProfile(id: String) async throws {
        try await databaseService.delete(id: id)
    }
    
}
