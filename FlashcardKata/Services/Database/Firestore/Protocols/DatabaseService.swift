//
//  DatabaseService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Protocol that defines the basic requirements for interacting with a database for a specified document type.

import Foundation

protocol DatabaseService {
    associatedtype Document: Codable
    
    // MARK: CRUD Methods
    func create(_ document: Document) async throws
    func updateDocument(_ document: Document) async throws
    func updateDocumentFields(id: String, updates: [DatabaseUpdate]) async throws
    func delete(id: String) async throws
    func deleteAll(userID: String) async throws
    
    // MARK: Fetch & Query Methods
    func fetchAll(userID: String, documentLimit: Int?) async throws -> [Document]
    func fetch(id: String) async throws -> Document?
    func fetchDocuments(ids: [String]) async throws -> [Document]
    func query(predicates: [QueryPredicate], userID: String, documentLimit: Int?) async throws -> [Document]
    func queryPaginatedDocuments(predicates: [QueryPredicate], userID: String, lastDocumentID: String) async throws -> [Document]
    func hasDocument(userID: String) async throws -> Bool
    func hasDocument(predicates: [QueryPredicate], userID: String) async throws -> Bool
}
