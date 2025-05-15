//
//  FetchURLData.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to fetch and decode data from a provided URL string.

import Foundation

/// Function to fetch and decode data from a URL string.
/// - Parameter urlString: The URL string to fetch data from.
/// - Throws: `AppError.networkError` if the URL is invalid or network request fails.
/// - Returns: An array of decoded objects of type `T`.
func fetchURLData<T: Decodable>(from urlString: String) async throws -> [T] {
    guard let url = URL(string: urlString) else {
        throw AppError.systemError
    }

    do {
        let (data, _) = try await URLSession.shared.data(from: url)

        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([T].self, from: data)
        return decodedData
    } catch {
        if error is URLError {
            throw AppError.networkError
        } else {
            throw AppError.systemError
        }
    }
}
