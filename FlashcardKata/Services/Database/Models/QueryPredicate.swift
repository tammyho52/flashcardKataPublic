//
//  QueryPredicate.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that defines different query predicates for database query construction.

import Foundation

/// Enum representing different query predicates used to modify database queries.
enum QueryPredicate {
    // MARK: - Field Comparison Predicates
    case isEqualTo(field: String, value: Any?)
    case isIn(field: String, values: [Any])
    case isNotIn(field: String, values: [Any])
    case arrayContains(field: String, value: Any)
    case arrayContainsAny(field: String, values: [Any])
    case isLessThan(field: String, value: Any)
    case isGreaterThan(field: String, value: Any)
    case isLessThanOrEqualTo(field: String, value: Any)
    case isGreaterThanOrEqualTo(field: String, value: Any)

    // MARK: - Query Modification Predicates
    case orderBy(field: String, descending: Bool)
    case limitTo(field: Int)
    case limitToLast(field: Int)
    case isNull(field: String)
    case isNotNull(field: String)
}

extension QueryPredicate: Equatable {
    // Equality check only checks for predicate equality, regardless of the associated field and values.
    static func == (lhs: QueryPredicate, rhs: QueryPredicate) -> Bool {
        switch (lhs, rhs) {
        case (.isEqualTo, .isEqualTo),
            (.isIn, .isIn),
            (.isNotIn, .isNotIn),
            (.arrayContains, .arrayContains),
            (.arrayContainsAny, .arrayContainsAny),
            (.isLessThan, .isLessThan),
            (.isGreaterThan, .isGreaterThan),
            (.isLessThanOrEqualTo, .isLessThanOrEqualTo),
            (.isGreaterThanOrEqualTo, .isGreaterThanOrEqualTo),
            (.orderBy, .orderBy),
            (.limitTo, .limitTo),
            (.limitToLast, .limitToLast),
            (.isNull, .isNull),
            (.isNotNull, .isNotNull):
            return true
        default:
            return false
        }
    }
}
