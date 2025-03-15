//
//  SubdeckName.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Represents the name of subdeck with unique identifier. 

import Foundation

struct SubdeckName: Identifiable, Equatable {
    let id: String
    var name: String

    init(id: String = UUID().uuidString, name: String = "") {
        self.id = id
        self.name = name
    }
}
