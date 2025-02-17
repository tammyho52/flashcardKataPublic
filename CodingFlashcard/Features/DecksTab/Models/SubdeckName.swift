//
//  SubdeckName.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import Foundation

struct SubdeckName: Identifiable, Equatable {
    let id: String
    var name: String
    
    init(id: String = UUID().uuidString, name: String = "") {
        self.id = id
        self.name = name
    }
}
