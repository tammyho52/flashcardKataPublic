//
//  OrderItemsByKeyPath.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility method to order items by a set of key paths and a sort operator.

import Foundation

/// Function to order items by multiple key paths using a custom sort operator.
func orderItemsByKeyPaths<T, V: Comparable>(
    items: inout [T],
    orderBy keyPaths: [KeyPath<T, V>],
    sortOperator: @escaping (V, V) -> Bool
) -> [T] {
    return items.sorted { lhs, rhs in
        for keyPath in keyPaths {
            let lhsValue = lhs[keyPath: keyPath]
            let rhsValue = rhs[keyPath: keyPath]
            if lhsValue != rhsValue {
                return sortOperator(lhsValue, rhsValue)
            }
        }
        return false
    }
}
