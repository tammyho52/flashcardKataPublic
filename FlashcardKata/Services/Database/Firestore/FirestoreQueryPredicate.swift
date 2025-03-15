//
//  FirestoreQueryPredicate.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum that defines different query predicates used to modify Firestore queries.

import Foundation
import FirebaseFirestore

enum QueryPredicate {

    // MARK: - Comparison Predicates
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

    // MARK: - Apply Method
    /// Modifies a Firestore query based on the selected predicate.
    func apply(to query: Query) -> Query {
        var query: Query = query

        switch self {
        case let .isEqualTo(field, value):
            if let value {
                query = query.whereField(field, isEqualTo: value)
            } else {
                query = query.whereField(field, isEqualTo: NSNull())
            }
        case let .isIn(field, values):
            query = query.whereField(field, in: values)
        case let .isNotIn(field, values):
            query = query.whereField(field, notIn: values)
        case let .arrayContains(field, value):
            query = query.whereField(field, arrayContains: value)
        case let .arrayContainsAny(field, values):
            query = query.whereField(field, arrayContainsAny: values)
        case let .isLessThan(field, value):
            query = query.whereField(field, isLessThan: value)
        case let .isGreaterThan(field, value):
            query = query.whereField(field, isGreaterThan: value)
        case let .isLessThanOrEqualTo(field, value):
            query = query.whereField(field, isLessThanOrEqualTo: value)
        case let .isGreaterThanOrEqualTo(field, value):
            query = query.whereField(field, isGreaterThanOrEqualTo: value)
        case let .orderBy(field, descending):
            query = query.order(by: field, descending: descending)
        case let .limitTo(limit):
            query = query.limit(to: limit)
        case let .limitToLast(limit):
            query = query.limit(toLast: limit)
        case let .isNull(field):
            query = query.whereField(field, isEqualTo: NSNull())
        case let .isNotNull(field):
            query = query.whereField(field, isNotEqualTo: NSNull())
        }
        return query
    }
}
