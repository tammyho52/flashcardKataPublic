//
//  OrderItemsByKeyPath.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

func orderItemsByKeyPaths<T, V: Comparable>(items: inout [T], orderBy keyPaths: [KeyPath<T, V>], sortOperator: @escaping (V, V) -> Bool) -> [T] {
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
