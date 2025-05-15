//
//  FirestoreQueryPredicateBuilder.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This structure provides a centralized mechanism for constructing Firestore queries using a variety of query predicates.

import Foundation
import FirebaseFirestore

/// A builder for constructing Firestore queries using query predicates.
struct FirestoreQueryPredicateBuilder {
    /// Builds a Firestore query based on the provided predicate and existing query.
    /// - Parameters:
    ///   - predicate: The predicate to apply to the query.
    ///   - query: The existing query to modify.
    /// - Returns: The updated query with the applied predicate.
    static func buildQuery(from predicate: QueryPredicate, for query: Query) -> Query {
        var updatedQuery = query

        switch predicate {
        case let .isEqualTo(field, value):
            if let value {
                updatedQuery = updatedQuery.whereField(field, isEqualTo: value)
            } else {
                updatedQuery = updatedQuery.whereField(field, isEqualTo: NSNull())
            }
        case let .isIn(field, values):
            updatedQuery = updatedQuery.whereField(field, in: values)
        case let .isNotIn(field, values):
            updatedQuery = updatedQuery.whereField(field, notIn: values)
        case let .arrayContains(field, value):
            updatedQuery = updatedQuery.whereField(field, arrayContains: value)
        case let .arrayContainsAny(field, values):
            updatedQuery = updatedQuery.whereField(field, arrayContainsAny: values)
        case let .isLessThan(field, value):
            updatedQuery = updatedQuery.whereField(field, isLessThan: value)
        case let .isGreaterThan(field, value):
            updatedQuery = updatedQuery.whereField(field, isGreaterThan: value)
        case let .isLessThanOrEqualTo(field, value):
            updatedQuery = updatedQuery.whereField(field, isLessThanOrEqualTo: value)
        case let .isGreaterThanOrEqualTo(field, value):
            updatedQuery = updatedQuery.whereField(field, isGreaterThanOrEqualTo: value)
        case let .orderBy(field, descending):
            updatedQuery = updatedQuery.order(by: field, descending: descending)
        case let .limitTo(limit):
            updatedQuery = updatedQuery.limit(to: limit)
        case let .limitToLast(limit):
            updatedQuery = updatedQuery.limit(toLast: limit)
        case let .isNull(field):
            updatedQuery = updatedQuery.whereField(field, isEqualTo: NSNull())
        case let .isNotNull(field):
            updatedQuery = updatedQuery.whereField(field, isNotEqualTo: NSNull())
        }
        
        return updatedQuery
    }
}
