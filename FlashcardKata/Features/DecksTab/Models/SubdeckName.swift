//
//  SubdeckName.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A data model representing the name of a subdeck.

import Foundation

/// A model representing the name of a subdeck.
struct SubdeckName: Identifiable, Equatable {
    let id: String
    var name: String
    
    // Provides default values for the properties.
    init(id: String = UUID().uuidString, name: String = "") {
        self.id = id
        self.name = name
    }
}
