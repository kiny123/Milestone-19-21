//
//  Notes.swift
//  Milestone 19-21
//
//  Created by nikita on 08.03.2023.
//

import UIKit

class Notes: Codable {
    
    var name: String?
    var text: String?
    var notesKey: String
    
    init(name: String, text: String) {
        self.name = name
        self.text = text
    }
}
