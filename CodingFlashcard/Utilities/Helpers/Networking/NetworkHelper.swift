//
//  NetworkHelper.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

struct NetworkHelper {
    static func checkAvailability<T>(
        value: T,
        field: String,
        checkAvailabilityFunction: @escaping (T) async throws -> Bool
    ) async throws -> String? {
        let isAvailable = try await checkAvailabilityFunction(value)
        return isAvailable ? nil : "\(field) is already taken"
    }
}
