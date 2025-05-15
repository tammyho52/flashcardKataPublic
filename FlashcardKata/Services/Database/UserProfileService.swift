//
//  UserProfileManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class is responsible for managing user profile data in Firebase.

import Foundation
import Firebase
import FirebaseFirestore

/// A service for managing user profile data in Firebase.
final class UserProfileService {
    // MARK: - Properties
    private let databaseService: FirestoreService<UserProfile, String>

    // MARK: - Initializer
    init() {
        self.databaseService = FirestoreService<UserProfile, String>(
            collectionPathType: .userProfile,
            orderByKeyPath: \UserProfile.id
        )
    }
    
    // MARK: - CRUD Operations
    func createUserProfile(_ userProfile: UserProfile) async throws {
        try await databaseService.create(userProfile)
    }

    func fetchUserProfile(id: String) async throws -> UserProfile? {
        return try await databaseService.fetch(id: id)
    }

    func updateUserProfile(_ userProfile: UserProfile) async throws {
        try await databaseService.updateDocument(userProfile)
    }

    func deleteUserProfile(id: String) async throws {
        try await databaseService.delete(id: id)
    }
}
