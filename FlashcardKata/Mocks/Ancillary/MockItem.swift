//
//  MockItem.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Mock Item used for testing and debugging purposes.

import Foundation

#if DEBUG
struct MockItem: Firestorable, Identifiable {
    var id: String
    var userID: String?
    
    static func firestoreFieldName(for keyPath: AnyKeyPath) -> String {
        switch keyPath {
        case \MockItem.id:
            return "id"
        case \MockItem.userID:
            return "userID"
        default:
            return ""
        }
    }
}

extension MockItem {
    static func createItems(count: Int) -> [MockItem] {
        return (0..<count).map { _ in
            MockItem(id: "\(UUID().uuidString)", userID: nil)
        }
    }
}
#endif
