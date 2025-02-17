//
//  FetchURLData.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

enum FetchError: Error {
    case invalidURL
    case decodingError
    case networkError(Error)
}

func fetchURLData<T: Decodable>(from urlString: String) async throws -> [T] {
    guard let url = URL(string: urlString) else {
        throw FetchError.invalidURL
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([T].self, from: data)
        return decodedData
    } catch {
        if let urlError = error as? URLError {
            throw FetchError.networkError(urlError)
        } else {
            throw FetchError.decodingError
        }
    }
}
